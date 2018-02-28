class Post

    attr_reader :id, :user, :text, :group, :date

    def initialize(*args)
        db = SQLite3::Database.open('db/db.sqlite')

        @id = args[0]
        if args.length == 5
            @date = args[1]
            @text = args[2]
            @user = User.new(args[3])
            group_id = args[4]
            if group_id
                @group = Group.new(group_id)
            else
                @group = nil
            end
        else
            arr = db.execute('SELECT * FROM posts WHERE id IS ?', @id)[0]
            @date = arr[1]
            @text = arr[2]
            @user = User.new(arr[3])
            group_id = arr[4]
            if group_id
                @group = Group.new(group_id)
            else
                @group = nil
            end
        end
    end

    def self.new_post(user_id, text, app)
        db = SQLite3::Database.open('db/db.sqlite')
        date = Time.now.strftime("%Y-%m-%d %H:%M")
        db.execute('INSERT INTO posts (upload_date, text, user_id) VALUES (?, ?, ?)', [date, text, user_id])
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

end