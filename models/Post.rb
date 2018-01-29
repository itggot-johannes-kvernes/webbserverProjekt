class Post

    def initialize(id)
        @id = id                # Is this even needed?
    end

    def self.start_page_posts(user_id, app)
        db = SQLite3::Database.open('db/db.sqlite')
        posts = db.execute('SELECT * FROM posts WHERE user_id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR user_id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?)', [user_id, user_id])
        return posts
    end

    def self.new_post(user_id, text, app)
        db = SQLite3::Database.open('db/db.sqlite')
        date = Time.now.strftime("%Y-%m-%d %H:%M")
        db.execute('INSERT INTO posts (upload_date, text, user_id) VALUES (?, ?, ?)', [date, text, user_id])
        app.redirect '/'
    end

end