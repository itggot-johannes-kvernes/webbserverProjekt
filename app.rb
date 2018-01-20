class App < Sinatra::Base

    enable :sessions

    get '/' do

        slim :'start_page'

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

end