class Model

    def initialize(args)
        db = SQLite3::Database.open('db/db.sqlite')

        p args
        p @columns

        if args.length == @columns.length
            @columns.length.times do |i|
                if @columns[i] = "group_id" && self.class != Group.class
                    if args[i]
                        @group = Group.new(args[i])
                    else
                        @group = nil
                    end
                end
            end
        else
            arr = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", args[0])[0]
            @columns.length.times do |i|
                if @columns[i] = "group_id" && self.class != Group.class
                    if arr[i]
                        @group = Group.new(arr[i])
                    else
                        @group = nil
                    end
                end
            end
        end
    end

    def self.table_name(name)
        @table_name = name
    end

    def self.columns(names)
        @columns = names
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