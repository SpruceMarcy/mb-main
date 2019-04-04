require 'net/smtp'
require 'zip'
require 'httparty'
require 'pg'
require 'sinatra'
    set :bind, '0.0.0.0'

password=ENV["master_password"]
adminuid=ENV["master_name"]

config = {
    :consumer_key => ENV["consumer_key"],
    :consumer_secret => ENV["consumer_secret"],
    }
conn = PG.connect("ec2-54-75-230-253.eu-west-1.compute.amazonaws.com", 5432,"","", "d11hc43cj4nptk", "gnwolwiiioiuqg", "32a08f6419e9ca49e69dd51f38373121570f08975f86f316f6f98b322087cad2")

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

get "/tools/wordrand" do
    @randword=randword()
    erb :wordrand
end
get "/tools/yourand" do
    queryword=randword()
    searchresults =HTTParty.get("https://www.googleapis.com/youtube/v3/search?key="+ENV["you_key"]+"&part=snippet&q="+queryword)
    videos = searchresults["items"]
    videos.reverse.each do |video|
        if video["id"]["kind"]=="youtube#video"
             redirect "https://youtu.be/"+video["id"]["videoId"]
        end
    end
end
get "/blog" do
    @isadmin=session[:uid]==adminuid
    @entries=conn.exec("SELECT * FROM Blog;")
    erb :blog
end
get "/blog/delete" do
    result=conn.exec("DELETE FROM Blog WHERE id=#{params["id"]};")
end 
get "/blog/add" do
    if session[:uid]==adminuid
        erb :blogadd
    end
end
post "/blog/add" do
    if session[:uid]==adminuid
        result=conn.exec("INSERT INTO Blog(id, date, title, content) VALUES (0, TIMESTAMP \'#{conn.exec("SELECT NOW();")[0]["now"]}\', \'#{params{:title}}\', \'#{params[:content]}\');")
        redirect "/blog"
    end
end
get "/contact" do
    erb :contact
end
post "/contact" do
    responsetoken=params["g-recaptcha-response"]
    if (HTTParty.post('https://www.google.com/recaptcha/api/siteverify',:query => {
        :secret=>ENV["reCAPTCHA_secret"],
        :response=>responsetoken
        })["success"])
    
        message = params[:message]
        if message.strip==""
           redirect "/botfailure" 
        end
        msg="From: MB-Main <"+ENV["master_email"]+">\nTo: Marcy Brook <"+ENV["master_email"]+">\nSubject: A Message from a Site Visitor ("+request.ip+").\n\n" + message + "\n\n"
        smtp = Net::SMTP.new 'smtp.gmail.com', 587
        smtp.enable_starttls
        smtp.start('smtp.gmail.com', ENV["master_email"], password, :login) do
            smtp.send_message(msg, '', ENV["master_email"])
        end
        redirect "/"
    else
        redirect "/botfailure"
    end
end

def randword()
    Zip::File.open('public/words_alpha.zip') do |zip_file|
        entry = zip_file.glob('*.txt').first
        content = entry.get_input_stream.read 
        content.split("\n").sample
    end
end