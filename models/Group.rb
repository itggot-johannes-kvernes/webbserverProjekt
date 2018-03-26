class Group < Model

    attr_reader :id, :name
    

    def initialize(*args)
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     @id = args[0]
    #     if args.length == 2
    #         @name = args[1]
    #     else
    #         arr = db.execute('SELECT * FROM groups WHERE id IS ?', @id)[0]
    #         @name = arr[1]
    #     end
        
        self.class.table_name 'groups'
        self.class.columns ["id", "name"]
        super(args)
    end

    def self.create(name, app)
        # DO SOMETHING IF THE NAME IS WRONG
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