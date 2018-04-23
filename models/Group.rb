class Group < Model

    attr_reader :id, :name
    

    def initialize(args)
        table_name 'groups'
        columns ["id", "name"]
        super(args)
    end

    # Allows a user to join a group
    #
    # @param user_id [Integer] the id of the user
    # @param group_name [String] the name of the group
    def self.join(user_id, group_name)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO memberships (group_id, user_id) VALUES ((SELECT id FROM groups WHERE name IS ?), ?)', [group_name, user_id])
    end
end