class Post

    attr_reader :id, :user, :text, :group, :date

    def self.start_page_posts(user_id)
    def initialize(*args)
        db = SQLite3::Database.open('db/db.sqlite')
        posts = db.execute('SELECT * FROM posts WHERE user_id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR user_id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?)', [user_id, user_id]).reverse

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

end