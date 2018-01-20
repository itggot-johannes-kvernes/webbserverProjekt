class User

    def initialize(id, username)
        @user_id = id
        @username = username
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
