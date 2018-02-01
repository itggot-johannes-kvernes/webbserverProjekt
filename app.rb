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
        if session[:user_id]
            @usernames = User.all_usernames_except_own_and_friends(session[:user_id])
            slim :'profile'
        else
            redirect '/'
        end
    end
end