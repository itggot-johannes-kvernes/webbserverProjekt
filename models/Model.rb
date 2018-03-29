class Model

    def initialize(args)
        db = SQLite3::Database.open('db/db.sqlite')

        if args.length == @columns.length
            arr = args
        else
            arr = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", args[0])[0]
        end

        @columns.length.times do |i|
            if @columns[i] == "group_id"
                if arr[i]
                    @group = Group.new(arr[i])
                else
                    @group = nil
                end
            elsif @columns[i] == "user_id"
                @user = User.new(arr[i])
            else
                instance_variable_set("@" + @columns[i], arr[i])
            end
        end
    end

    def table_name(name)
        @table_name = name
    end

    def columns(columns)
        @columns = columns
    end



    def self.one_with_id(id)
        db = SQLite3::Database.open('db/db.sqlite')
        db_result = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", id)[0]

        if db_result.length == 2 || db_result.length == 3
            return self.new(db_result[0], db_result[1])
        elsif db_result.length == 5
            return self.new(db_result[0], db_result[1], db_result[2], db_result[3], db_result[4])
        else
            puts "We got a problem"
            return nil
        end
    end
end