class Model

    def initialize(args)
        
        db = SQLite3::Database.open('db/db.sqlite')
        db.results_as_hash = true

        if args.length == @columns.length
            to_be_inserted = args
        else
            temp = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", args[:id])[0]
            temp.reject { |k, v| k.class == Integer }
            to_be_inserted = {}
            for key in temp.keys
                if key.class == String
                    to_be_inserted[key.to_sym] = temp[key]
                end
            end
        end

        to_be_inserted.each do |k, v|
            if k == :group_id
                if v
                    @group = Group.new( {id: v} )
                else
                    @group = nil
                end
            elsif k == :user_id
                @user = User.new( {id: v} )
            else
                instance_variable_set("@" + k.to_s, v)
            end
        end
        db.results_as_hash = false
    end

    # Sets the table_name instance variable for later use
    #
    # @param name [String] the table name
    def table_name(name)
        @table_name = name
    end

    # Sets the columns instance variable for later use
    #
    # @param columns [Array] array of column names
    def columns(columns)
        @columns = columns
    end


    # Redundant since the .new method covers this
    #
    # def self.one_with_id(id)
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     db_result = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", id)[0]

    #     if db_result.length == 2 || db_result.length == 3
    #         return self.new(db_result[0], db_result[1])
    #     elsif db_result.length == 5
    #         return self.new(db_result[0], db_result[1], db_result[2], db_result[3], db_result[4])
    #     else
    #         puts "We got a problem"
    #         return nil
    #     end
    # end
end