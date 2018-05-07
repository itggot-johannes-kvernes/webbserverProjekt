class Post < Model

    attr_reader :id, :user, :text, :group, :upload_date


    def initialize(args)
        table_name "posts"
        columns ["id", "upload_date", "text", "user_id", "group_id"]
        super(args)
    end

    def self._table_name
        return "posts"
    end

    def self._columns
        return ["id", "upload_date", "text", "user_id", "group_id"]
    end
    
end