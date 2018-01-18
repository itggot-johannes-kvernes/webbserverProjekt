class App < Sinatra::Base

    enable :sessions

    get '/' do

        slim :'start_page'

    end

    get '/create_user' do

        slim :'create_user'

    end

end