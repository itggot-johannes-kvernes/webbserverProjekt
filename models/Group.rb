class Group

    attr_reader :id, :name

    def self.all_groups_except_joined(user_id)
    def initialize(*args)
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT name FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id IS ?)', user_id)
        @id = args[0]
        if args.length == 2
            @name = args[1]
        else
            arr = db.execute('SELECT * FROM groups WHERE id IS ?', @id)[0]
            @name = arr[1]
        end
    end

    def self.create(name, app)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO groups (name) VALUES (?)', name)
        app.redirect "/users/#{app.session[:user_id]}"
    end

    def self.join(user_id, group_name, app)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO memberships (group_id, user_id) VALUES ((SELECT id FROM groups WHERE name IS ?), ?)', [group_name, user_id])
        app.redirect "/users/#{app.session[:user_id]}"
    end

end