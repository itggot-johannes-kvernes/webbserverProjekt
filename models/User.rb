class User

    attr_reader :id, :username

    def initialize(id, username)
        @user_id = id
        @username = username
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

    def self.username_from_posts(posts)
        db = SQLite3::Database.open('db/db.sqlite')
        users = []

        for i in posts
            users << db.execute('SELECT username FROM users WHERE id IS ?', i[3])[0][0]
        end

        return users
    end

    def self.all_usernames_except_own_and_friends(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT username FROM users WHERE id NOT IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) AND id NOT IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) AND id IS NOT ?', [user_id, user_id, user_id])
    end

    def self.add_friend(user1_id, name)
        db = SQLite3::Database.open('db/db.sqlite')
        user2_id = db.execute('SELECT id FROM users WHERE username IS ?', name)
        db.execute('INSERT INTO friendships (user1_id, user2_id) VALUES (?, ?)', [user1_id, user2_id])
    end

end