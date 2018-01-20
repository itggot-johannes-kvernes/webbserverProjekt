class User

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
                user_id = db.execute('SELECT id FROM users WHERE username IS ?', username)
                app.session[:user] = User.new(user_id, username)
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
            app.redirect '/'
        else
            app.redirect '/unable_to_create_user'
        end
    end

end
