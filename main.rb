require 'net/smtp'
require 'sinatra'
    set :bind, '0.0.0.0'

password=''
config = {
    :consumer_key => ,
    :consumer_secret => ,
    }

enable :sessions
set :session_secret, 'key goes here'

get "/login" do
    redirect '/'
end
get '/auth/:name/callback' do
    redirect '/'
end

get "/logout" do
    session[:uid] = nil
    redirect '/'
end

get "/" do
    erb :index
end
get "/tools" do
    erb :tools
end
get "/tools/" do
    erb :toolsdirectory
end
get "/projects" do
    erb :projects
end
get "/projects/" do
    erb :projectsdirectory
end
get "/about" do
    erb :about
end
get "/tools/settings" do
    erb :settings
end

post "/tools/settings/admin" do
   if !params[:password].nil?
       password=params[:password] 
   end
   redirect "/tools/"
end
post "/tools/settings/session" do
   session[:debug]=!params[:debug].nil?
   redirect "/tools/"
end

get "/contact" do
    erb :contact
end
post "/contact" do
    message = params[:message]
    msg="From: MB-Main <mdr.brook@gmail.com>\nTo: Marcy Brook <mdr.brook@gmail.com>\nSubject: A Message from a Site Visitor.\n\n" + message + "\n\n"
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('localhost', "mdr.brook@gmail.com", password, :login) do
        smtp.send_message(msg, '', "mdr.brook@gmail.com")
    end
    redirect "/"
end