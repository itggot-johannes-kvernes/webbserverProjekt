class App < Sinatra::Base

    enable :sessions

    get '/' do
        if session[:user_id]
            @posts = Post.start_page_posts(session[:user_id])
            @users = User.username_from_posts(@posts)
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
            @users_friends = User.friends(session[:user_id])
            @users_groups = User.groups(session[:user_id])
            @usernames = User.all_usernames_except_own_and_friends(session[:user_id])
            @group_names = Group.all_groups_except_joined(session[:user_id])
            slim :'profile'
        else
            @friends = User.friends(params["id"].to_i)
            @groups = User.groups(params["id"].to_i)
            @username = User.username_from_id(params["id"].to_i)
            slim :'other_user'
        end
    end

    post '/add_friend' do

        if params["name"] == "" || params["name"] == nil
            
        else
            User.add_friend(session[:user_id], params["name"])
        end

        redirect "/users/#{session[:user_id]}"
    end

    post '/delete_account' do
        if params["confirmation"] == "YES"
            User.delete(session[:user_id])
            session.destroy
            redirect '/'
        else
            redirect "/users/#{session[:user_id]}"
        end
        
    end

    post '/create_group' do
        Group.create(params["group_name"], self)
    end

    post '/join_group' do
        Group.join(session[:user_id], params["name"], self)
    end
end