require 'net/smtp'
require 'omniauth'
require 'omniauth-microsoft-live'
require 'sinatra'
    set :bind, '0.0.0.0'

password=''
config = {
    :consumer_key => "2479916b-8035-4981-b2e2-3b48b883ebe8",
    :consumer_secret => "d!?>O|6$_};&})**{{>.>Z;#.^/}^&^^(={;?!*})^_?^/$)J{({}.",
    }

use OmniAuth::Builder do
  provider :microsoft_live, 
    {client_id: config[:consumer_key],
        client_secret: config[:consumer_secret],
        redirect_uri:"https://mb-main-test.herokuapp.com/auth/azure_oauth2/callback",
        callback_path: "https://mb-main-test.herokuapp.com/auth/azure_oauth2/callback",
        scope: "https://graph.microsoft.com/User.Read",
      #tenant_id: ENV['AZURE_TENANT_ID']
    }
end

enable :sessions
set :session_secret, 'key goes here'

get "/login" do
    redirect '/auth/microsoft_live'
end
get '/auth/:name/callback' do
    auth = request.env["omniauth.state"]
    #puts "=========================="
    #puts "This is auth:"
    #puts auth
    #puts "=========================="
    #outstring=""
    #auth.each do |key, value|
    #    outstring=outstring + " & " + key.to_s + ' : ' + value.to_s
    #end
    session[:uid] = auth[:uid]
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