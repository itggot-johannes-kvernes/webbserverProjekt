class App < Sinatra::Base

    get '/create_user' do
        slim :'create_user'
    end

    get '/*' do     # Det här är typ before-filtret, men jag behövde lägga 'create_user' innan
        if session[:user_id]
            @user = User.new( {id: session[:user_id], username: session[:username]} )
            pass
        else
            redirect '/create_user'
        end
    end
    
    get '/' do
        @posts = @user.start_page_posts     # Kan inte använda Post.all med restrictions här för den behöver vara nestad
        slim :'start_page'
    end

    post '/new_user' do
        if User.add_to_db(params["username"], params["password"], params["key"])
            redirect '/'
        else
            redirect '/unable_to_create_user'
        end
    end

    get '/unable_to_create_user' do
        slim :'unable_to_create_user'
    end

    post '/login' do
        login = User.login(params["username"], params["password"])
        if login
            session[:user_id] = login
            session[:username] = params["username"]
        end
        redirect '/'
    end

    post '/logout' do
        session.destroy
        redirect '/'
    end

    post '/new_post' do
        if params["text"] != "" && params["text"] != nil
            post = Post.new( {id: nil, upload_date: Time.now.strftime("%Y-%m-%d %H:%M"), text: params["text"], user_id: session[:user_id], group_id: nil} )
            post.add_to_db
        end
        redirect '/'
    end

    get '/users/:id' do
        if session[:user_id] == params["id"].to_i
            @user = User.new( {id: session[:user_id]} )
            @users_friends = @user.friends
            @users_groups = @user.groups
            @unfriended_users = @user.all_usernames_except_own_and_friends
            @unjoined_groups = @user.unjoined_groups
            slim :'profile'
        else
            @posts = Post.all("posts.id AS post_id", "upload_date", "text", "user_id", "group_id") { |_| {include: [[:users], ["users.id", "posts.user_id"]], restrictions: [["user_id", params["id"]], ["group_id", "NULL"]]} }
            @user = User.new( {id: params["id"].to_i} )
            @friends = @user.friends
            @groups = @user.groups
            slim :'other_user'
        end
    end

    post '/add_friend' do
        if params["name"] != "" && params["name"]
            @user = User.new( {id: session[:user_id]} )
            @user.add_friend(params["name"])
        end
        redirect "/users/#{session[:user_id]}"
    end

    post '/delete_account' do
        if params["confirmation"] == "YES"
            @user = User.new( {id: session[:user_id]})
            @user.delete
            session.destroy
            redirect '/'
        else
            redirect "/users/#{session[:user_id]}"
        end
    end

    post '/create_group' do
        if params["group_name"] == "" || params["group_name"] == nil
            redirect "/users/#{session[:user_id]}"
        else
            group = Group.new( {id: nil, name: params["group_name"]} )
            group.add_to_db
            redirect "/users/#{session[:user_id]}"
        end
    end

    post '/join_group' do
        if params["name"] != "" && params["name"]
            Group.join(session[:user_id], params["name"])
        end
        redirect "/users/#{session[:user_id]}"
    end

    get '/groups/:id' do
        @group = Group.new( {id: params["id"].to_i} )
        @posts = Post.all("posts.id AS post_id", "upload_date", "text", "user_id", "group_id") {|_| {include: [[:groups], ["groups.id", "group_id"]], restrictions: [["group_id", params["id"]]]}}
        slim :'group'
    end

    post '/new_group_post' do
        post = Post.new( {id: nil, upload_date: Time.now.strftime("%Y-%m-%d %H:%M"), text: params["text"], user_id: session[:user_id], group_id: params["group_id"].to_i} )
        post.add_to_db
        redirect "/groups/#{params['group_id']}"
    end
end