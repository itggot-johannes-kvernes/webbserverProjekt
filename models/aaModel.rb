class Model

    def initialize(args)

        @values = {}
        
        db = SQLite3::Database.open('db/db.sqlite')
        db.results_as_hash = true

        if args.length == @columns.length
            to_be_inserted = args
        else
            temp = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", args[:id])[0]
            temp.reject { |k, v| k.class == Integer }
            to_be_inserted = {}
            for key in temp.keys
                to_be_inserted[key.to_sym] = temp[key] if key.class == String
            end
        end

        to_be_inserted.each do |k, v|
            @values[k] = v
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

    # Adds new instances to the database
    #
    #
    def add_to_db
        db = SQLite3::Database.open('db/db.sqlite')
        str = "INSERT INTO #{@table_name} ("

        (@values.length - 2).times do |i|
            str += "#{@values.keys[i + 1].to_s}, "
        end
        str += "#{@values.keys[-1].to_s}"

        str += ") VALUES ("
        (@values.length - 2).times do
            str += "?, "
        end
        str += "?)"

        to_be_inserted = @values.values
        to_be_inserted.delete_at(0)

        db.execute(str, to_be_inserted)
    end

    # Gets all instances of a user, group or post from database, with restrictions
    #
    # @param args [Array<String>] the wanted database columns
    # @param block [Hash<Array<String>>]
    def self.all(*args, &block)
        db = SQLite3::Database.open('db/db.sqlite')
        query = "SELECT"
        if args.length > 0
            for i in args
                query += !(i == args[-1]) ? " " + i + "," : " " + i
            end
        else
            query += " *"
        end

        query += " FROM #{self._table_name}"

        if block_given?
            block = block.call
            if block.keys.include? :include
                query += " INNER JOIN "
                query += block[:include][0][0].to_s
                query += " ON "
                query += block[:include][1][0]
                query += " IS "
                query += block[:include][1][1]
            end

            if block.keys.include? :restrictions
                for i in block[:restrictions]
                    query += i == block[:restrictions][0] ? " WHERE " : " AND "
                    query += i[0]
                    query += " IS "
                    query += i[1]
                end
            end
        end

        objects = []

        db.results_as_hash = true
        for i in db.execute(query)
            hash = {}
            i.each do |k, v|
                hash[k.to_sym] = v if self._columns.include?(k) || k == "id"
            end
            objects << self.new(hash)
        end
        db.results_as_hash = false

        return self.class == Post.class ? objects.reverse : objects
    end
    
end