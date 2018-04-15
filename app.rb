class App < Sinatra::Base

    enable :sessions

    get '/' do

        if session[:user_id]
            @user = User.new( {id: session[:user_id]} )
            @posts = @user.start_page_posts     # Kan inte använda Post.all med restrictions här för den behöver vara nestad
            slim :'start_page'
        else
            slim :'create_user'
        end
    end

    get '/create_user' do
        slim :'create_user'
    end

    post '/new_user' do
        User.new_user(params["username"], params["password"], params["key"], self)
    end

    get '/unable_to_create_user' do
        slim :'unable_to_create_user'
    end

    post '/login' do
        User.login(params["username"], params["password"], self)
    end

    post '/logout' do
        session.destroy
        redirect '/'
    end

    post '/new_post' do
        if params["text"] == "" || params["text"] == nil
            redirect '/'
        else
            Post.new_post(session[:user_id], params["text"], self)
        end
    end

    get '/users/:id' do
        if !session[:user_id]
            redirect '/'
        elsif session[:user_id] == params["id"].to_i
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

        if params["name"] == "" || params["name"] == nil
            redirect "/users/#{session[:user_id]}"
        else
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
            Group.create(params["group_name"], self)
        end
    end

    post '/join_group' do
        if params["name"] == "" || params["name"] == nil
            redirect "/users/#{session[:user_id]}"
        else
            Group.join(session[:user_id], params["name"], self)
        end
    end

    get '/groups/:id' do
        if !session[:user_id]
            redirect '/'
        else
            # @test_posts = Post.all("posts.id AS post_id", "upload_date", "text", "user_id", "group_id") {|_| {include: [[:groups], ["groups.id", "group_id"]], restrictions: [["group_id", params["id"]]]}}
            # p @test_posts
            @group = Group.new( {id: params["id"].to_i} )
            @posts = Post.all("posts.id AS post_id", "upload_date", "text", "user_id", "group_id") {|_| {include: [[:groups], ["groups.id", "group_id"]], restrictions: [["group_id", params["id"]]]}}
            slim :'group'
        end
    end

    post '/new_group_post' do
        Post.new_group_post(session[:user_id], params["text"], params["group_id"].to_i, self)
    end
end