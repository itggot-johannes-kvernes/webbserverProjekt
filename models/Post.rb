class Post < Model

    attr_reader :id, :user, :text, :group, :upload_date
    

    def initialize(*args)
    #     db = SQLite3::Database.open('db/db.sqlite')

    #     @id = args[0]
    #     if args.length == 5
    #         @date = args[1]
    #         @text = args[2]
    #         if args[3].class == Integer
    #             @user = User.new(args[3])
    #         else
    #             @user = User.new(args[3][0], args[3][1])
    #         end
    #         group_id = args[4]
    #         if group_id
    #             @group = Group.new(group_id)
    #         else
    #             @group = nil
    #         end
    #     else
    #         arr = db.execute('SELECT * FROM posts WHERE id IS ?', @id)[0]
    #         @date = arr[1]
    #         @text = arr[2]
    #         @user = User.new(arr[3])
    #         group_id = arr[4]
    #         if group_id
    #             @group = Group.new(group_id)
    #         else
    #             @group = nil
    #         end
    #     end

        table_name 'posts'
        columns ["id", "upload_date", "text", "user_id", "group_id"]

        super(args)
    end

    def self.new_post(user_id, text, app)
        db = SQLite3::Database.open('db/db.sqlite')
        date = Time.now.strftime("%Y-%m-%d %H:%M")
        db.execute("INSERT INTO #{@table_name} (upload_date, text, user_id) VALUES (?, ?, ?)", [date, text, user_id])
        app.redirect '/'
    end

    def self.group_posts(group_id)
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM posts WHERE group_id IS ?', group_id).reverse
        posts = []
        for i in db_arr
            posts << Post.new(i[0], i[1], i[2], i[3], i[4])
        end
        return posts
    end

    def self.new_group_post(user_id, text, group_id, app)
        db = SQLite3::Database.open('db/db.sqlite')
        date = Time.now.strftime("%Y-%m-%d %H:%M")
        db.execute('INSERT INTO posts (upload_date, text, user_id, group_id) VALUES (?, ?, ?, ?)', [date, text, user_id, group_id])
        app.redirect "/groups/#{group_id}"
    end

    def self.all(*args, &block)
        db = SQLite3::Database.open('db/db.sqlite')
        db_str = "SELECT"
        if args.length > 0
            for i in args
                if !(i == args[-1])
                    db_str += " " + i + ","
                else
                    db_str += " " + i
                end
            end
        else
            db_str += " *"
        end
        
        db_str += " FROM posts"

        if block_given?
            block = block.call
            if block.keys.include? :include
                db_str += " INNER JOIN "
                db_str += block[:include][0][0].to_s
                db_str += " ON "
                db_str += block[:include][1][0].to_s
                db_str += " IS "
                db_str += block[:include][1][1].to_s
            end

            if block.keys.include? :restrictions
                for i in block[:restrictions]
                    if i == block[:restrictions][0]
                        db_str += " WHERE "
                    else
                        db_str += " AND "
                    end
                    db_str += i[0]
                    db_str += " IS "
                    db_str += i[1]
                end
            end
        end
        
        posts = []
        db_arr = db.execute(db_str)

        for i in db_arr
            posts << Post.new(i[0], i[1], i[2], i[3], i[4])
        end

        return posts.reverse
    end
end