class User < Model

    attr_reader :id, :username
    

    def initialize(args)
        table_name 'users'
        columns ["id", "username"]
        super(args)
    end

    # Logs the user in if username and password are correct
    #
    # @param username [String] the submitted name of the user
    # @param password [String] the submitted password
    # @return [Integer] the id of the user that logged in
    def self.login(username, password)
        db = SQLite3::Database.open('db/db.sqlite')
        hash = db.execute('SELECT password FROM users WHERE username IS ?', username)[0]
        if hash
            stored_password = BCrypt::Password.new(hash[0])
            if stored_password == password
                user_id = db.execute('SELECT id FROM users WHERE username IS ?', username)[0][0]
                return user_id
            end
        end
    end

    # Adds an instance of a user to the database if accepted
    #
    # @param username [String] the name of the user
    # @param password [String] the password to the account
    # @param key [String] the key to check if the user is allowed to create an account
    # @return [Boolean] if the creation of the new account succseeded
    def self.add_to_db(username, password, key)
        db = SQLite3::Database.open('db/db.sqlite')
        db_array = db.execute('SELECT username FROM users')
        
        usernames = []
        for i in db_array
            usernames << i[0]
        end

        username_is_unused = !(usernames.include?(username))

        if username_is_unused && key == "4242"
            hash = BCrypt::Password.create(password)
            db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash])
            User.login(username, password)
            return true
        else
            return false
        end
    end

    # Gets the user's start page posts
    #
    # @return [Array<Post>] the array of start page posts
    def start_page_posts
        db = SQLite3::Database.open('db/db.sqlite')
        posts = []
        db_array = db.execute('SELECT * FROM posts WHERE group_id IS NULL AND user_id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR group_id IS NULL AND user_id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) OR group_id IS NULL AND user_id IS ?', [@id, @id, @id]).reverse
        for i in db_array
            posts << Post.new( {id: i[0], upload_date: i[1], text: i[2], user_id: i[3], group_id: i[4]} )
        end
        return posts
    end

    # Gets the users one user has not yet befriended
    #
    # @return [Array<User>] the array of users
    def all_usernames_except_own_and_friends
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM users WHERE id NOT IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) AND id NOT IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) AND id IS NOT ?', [@id, @id, @id])
        users = []
        for i in db_arr
            users << User.new( {id: i[0], username: i[1]} )
        end
        return users
    end

    # Gets the groups one user has not yet joined
    #
    # @return [Array<Group>] the array of groups
    def unjoined_groups
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id IS ?)', @id)
        groups = []
        for i in db_arr
            groups << Group.new( {id: i[0], name: i[1]} )
        end
        return groups
    end

    # Adds a friend to a user
    #
    # @param name [String] the name of the soon-to-be friend
    def add_friend(name)
        # DO SOMETHING IF THE NAME IS WRONG
        db = SQLite3::Database.open('db/db.sqlite')
        user2_id = db.execute('SELECT id FROM users WHERE username IS ?', name)
        db.execute('INSERT INTO friendships (user1_id, user2_id) VALUES (?, ?)', [@id, user2_id])
    end

    # Deletes everything about a user
    def delete
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('DELETE FROM memberships WHERE user_id IS ?', @id)
        db.execute('DELETE FROM friendships WHERE user1_id IS ? OR user2_id IS ?', [@id, @id])
        db.execute('DELETE FROM posts WHERE user_id IS ?', @id)
        db.execute('DELETE FROM users WHERE id IS ?', @id)
    end

    # Gets the friends of a user
    #
    # @return [Array<User>] the array of users
    def friends
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM users WHERE id IN (SELECT user1_id FROM friendships WHERE user2_id IS ?) OR id IN (SELECT user2_id FROM friendships WHERE user1_id IS ?) AND id IS NOT ?', [@id, @id, @id])
        friends = []
        for i in db_arr
            friends << User.new( {id: i[0], username: i[1]} )
        end
        return friends
    end

    # Gets the groups a user has joined
    #
    # @return [Array<Group>] the array of groups
    def groups
        db = SQLite3::Database.open('db/db.sqlite')
        db_arr = db.execute('SELECT * FROM groups WHERE id IN (SELECT group_id FROM memberships WHERE user_id IS ?)', @id)
        groups = []
        for i in db_arr
            groups << Group.new( {id: i[0], name: i[1]})
        end
        return groups
    end

end