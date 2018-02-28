class User

    attr_reader :id, :name

    def initialize(*args)
        db = SQLite3::Database.open('db/db.sqlite')
        @id = args[0]
        if args.length == 2
            @name = args[1]
        else
            arr = db.execute('SELECT * FROM users WHERE id IS ?', @id)[0]
            @name = arr[1]
        end
    end

    def self.login(username, password, app)
        db = SQLite3::Database.open('db/db.sqlite')
        hash = db.execute('SELECT password FROM users WHERE username IS ?', username)
        if hash != []
            hash = hash[0][0]
            stored_password = BCrypt::Password.new(hash)
            if stored_password == password
                user_id = db.execute('SELECT id FROM users WHERE username IS ?', username)[0][0]
                app.session[:user_id] = user_id
                app.session[:username] = username
                app.redirect '/'
            else
                app.redirect '/create_user'
            end
        else
            app.redirect '/create_user'
        end

    end

    def self.new_user(username, password, key, app)

        db = SQLite3::Database.open('db/db.sqlite')

        username_array = db.execute('SELECT username FROM users')
        username_is_unused = true

        if username_array.length != 0
            for i in username_array
                if username == i
                    username_is_unused = true
                end
            end
        end

        if username_is_unused && key == "4242"
            hash = BCrypt::Password.create(password)
            db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash])
            User.login(username, password, app)
        else
            app.redirect '/unable_to_create_user'
        end
    end

    def start_page_posts
        db = SQLite3::Database.open('db/db.sqlite')
        posts = []
        db_array = db.execute('SELECT * FROM posts WHERE group_id IS NULL AND user_id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR user_id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?)', [@id, @id]).reverse
        for i in db_array
            posts << Post.new(i[0], i[1], i[2], i[3], i[4])
        end
        return posts
    end

    def all_usernames_except_own_and_friends
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM users WHERE id NOT IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) AND id NOT IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) AND id IS NOT ?', [@id, @id, @id])
        users = []
        for i in db_arr
            users << User.new(i[0], i[1])
        end
        return users
    end

    def unjoined_groups
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id IS ?)', @id)
        groups = []
        for i in db_arr
            groups << Group.new(i[0], i[1])
        end
        return groups
    end

    def add_friend(name)
        # DO SOMETHING IF THE NAME IS WRONG
        db = SQLite3::Database.open('db/db.sqlite')
        user2_id = db.execute('SELECT id FROM users WHERE username IS ?', name)
        db.execute('INSERT INTO friendships (user1_id, user2_id) VALUES (?, ?)', [@id, user2_id])
    end

    def delete
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('DELETE FROM memberships WHERE user_id IS ?', @id)
        db.execute('DELETE FROM friendships WHERE user1_id IS ? OR user2_id IS ?', [@id, @id])
        db.execute('DELETE FROM posts WHERE user_id IS ?', @id)
        db.execute('DELETE FROM users WHERE id IS ?', @id)
    end

    def friends
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM users WHERE id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) AND id IS NOT ?', [@id, @id, @id])
        friends = []
        for i in db_arr
            friends << User.new(i[0], i[1])
        end
        return friends
    end

    def groups
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM groups WHERE id IN (SELECT group_id FROM memberships WHERE user_id IS ?)', @id)
        groups = []
        for i in db_arr
            groups << Group.new(i[0], i[1])
        end
        return groups
    end

end