class App < Sinatra::Base

    enable :sessions

    get '/' do
        if session[:user_id]
            @user = User.new(session[:user_id])
            @posts = @user.start_page_posts
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
        Post.new_post(session[:user_id], params["text"], self)
    end

    get '/users/:id' do
        if !session[:user_id]
            redirect '/'
        elsif session[:user_id] == params["id"].to_i
            @user = User.new(session[:user_id])
            @users_friends = @user.friends
            @users_groups = @user.groups
            @unfriended_users = @user.all_usernames_except_own_and_friends
            @unjoined_groups = @user.unjoined_groups
            slim :'profile'
        else
            @user = User.new(params["id"].to_i)
            @friends = @user.friends
            @groups = @user.groups
            slim :'other_user'
        end
    end

    post '/add_friend' do

        if params["name"] == "" || params["name"] == nil
            # ???
        else
            @user = User.new(session[:user_id])
            @user.add_friend(params["name"])
        end

        redirect "/users/#{session[:user_id]}"
    end

    post '/delete_account' do
        if params["confirmation"] == "YES"
            @user = User.new(session[:user_id])
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
        Group.join(session[:user_id], params["name"], self)
    end

    get '/groups/:id' do
        if !session[:user_id]
            redirect '/'
        else
            @group = Group.new(params["id"].to_i)
            @posts = Post.group_posts(params["id"].to_i)
            slim :'group'
        end
    end

    post '/new_group_post' do
        Post.new_group_post(session[:user_id], params["text"], params["group_id"].to_i, self)
    end
end