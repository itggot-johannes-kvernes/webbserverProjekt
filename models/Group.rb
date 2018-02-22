class Group

    def initialize(id)
        @id = id
    end

    def self.all_groups_except_joined(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT name FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id IS ?)', user_id)
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