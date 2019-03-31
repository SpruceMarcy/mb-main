require 'net/smtp'
require 'httparty'
require 'sinatra'
    set :bind, '0.0.0.0'

password=''
adminuid="SpruceMarcy"

config = {
    :consumer_key => ENV["consumer_key"],
    :consumer_secret => ENV["consumer_secret"],
    }

enable :sessions
set :session_secret, 'key goes here'

get "/login" do
    redirect 'https://github.com/login/oauth/authorize?client_id='+config[:consumer_key]+'&redirect_uri=http://mxmbrook.co.uk/callback' 
end
get '/callback' do
    userinformation = HTTParty.get('https://api.github.com/user?access_token='+HTTParty.post('https://github.com/login/oauth/access_token',:query => {
        :client_id=>config[:consumer_key],
        :client_secret=>config[:consumer_secret],
        :code=>params[:code],
        }, :headers=>{
        "Accept" => "application/json"
        })["access_token"])
    session[:uid]=userinformation["login"]
    session[:logo]=userinformation["avatar_url"]
    session[:logged_in]=true
    redirect "/"
end

get "/logout" do
    session[:uid] = nil
    session[:logo] = nil
    session[:logged_in] = false
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
    @isadmin= session[:uid]==adminuid
    erb :settings
end

post "/tools/settings/admin" do
   if session[:uid]==adminuid
       if !params[:password].nil?
           password=params[:password] 
       end
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