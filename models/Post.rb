class Post

    def initialize(id)
        @id = id
    end

    def self.start_page_posts(user_id, app)
        db = SQLite3::Database.open('db/db.sqlite')
        post_ids = db.execute('SELECT id FROM posts WHERE user_id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR user_id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?)', user_id)
        app.redirect '/'
    end

end