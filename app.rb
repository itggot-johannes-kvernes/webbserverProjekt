class App < Sinatra::Base

    enable :sessions

    get '/' do

        slim :'start_page'

    end

end