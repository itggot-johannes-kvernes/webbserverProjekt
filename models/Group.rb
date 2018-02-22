class Group

    def initialize(id)
        @id = id
    end

    def self.all_groups_except_joined(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT name FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id IS ?)', user_id)
    end
end