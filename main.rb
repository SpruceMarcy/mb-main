require 'net/smtp'
require 'zip'
require 'httparty'
require 'pg'
require 'sinatra'
    set :bind, '0.0.0.0'
require 'rack/ssl-enforcer'
use Rack::SslEnforcer

password=ENV["master_password"]
adminuid=ENV["master_name"]

config = {
    :consumer_key => ENV["consumer_key"],
    :consumer_secret => ENV["consumer_secret"],
    }
#connectinfo=ENV["DATABASE_URL"]
conndomain=ENV["data_dom"]
connport=ENV["data_port"].to_i
conndata=ENV["data_data"]
connuser=ENV["data_user"]
connpass=ENV["data_pass"]

include ERB::Util
conn = PG.connect(conndomain, connport,"","",conndata, connuser, connpass)

enable :sessions
set :session_secret, 'key goes here'


get "/login" do
    redirect 'https://github.com/login/oauth/authorize?client_id='+config[:consumer_key]+'&redirect_uri=https://mxmbrook.co.uk/callback' 
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
    @isadmin=session[:uid]==adminuid
    @entry=conn.exec("SELECT * FROM Blog WHERE id=#{getindex(conn)};")[0]
    erb :index
end
get "/tools/?" do
    erb :toolsdirectory
end

get "/projects/?" do
    erb :projectsdirectory
end
get "/about" do
    erb :about
end
get "/tools/settings" do
    @isadmin=session[:uid]==adminuid
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
post "/tools/settings/session/debug" do
    session[:debug]=!params[:debug].nil?
    redirect "/tools/settings"
end
post "/tools/settings/session/dyslexic" do
    session[:dyslexic]=!params[:dyslexic].nil?
    redirect "/tools/settings"
end
get "/tools/wordrand" do
    @randword=randword()
    erb :wordrand
end

#get "/tools/younew" do
#    
#    searchresults=HTTParty.get("https://www.googleapis.com/youtube/v3/search?key="+ENV["you_key"]+"&part=snippet&order=date&publishedAfter=#{(Time.now-3600).to_datetime.rfc3339}")
#    puts (Time.now-3600).to_datetime.rfc3339
#    puts "======================================="
#    videos = searchresults["items"]
#    videos.each do |video|
#        if video["id"]["kind"]=="youtube#video"
#             redirect "https://youtu.be/"+video["id"]["videoId"]
#        end#
#    end
#end

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
get "/tools/wordgen" do
    @randword=`java -jar tools/WordGenerator/wordgen.jar "/app/tools/WordGenerator/words_alpha.txt"`
    erb :wordgen
end
get "/tools/redrand" do
    sub=["tihi","tili"].sample
    redditposts=HTTParty.get("https://www.reddit.com/r/#{sub}/top/.json?t=month",:headers => {"User-agent" =>"Top post getter for tihi/tili roulette"})
    if redditposts["message"].nil? then
        @redpost=redditposts["data"]["children"].sample
    else
        @redtext=redditposts["message"]
    end
    erb :redrand
end
get "/tools/alpaca" do
    erb :alpaca
end
get "/tools/cells" do
    erb :cells
end
get "/tools/vic" do
    erb :vic
end
get "/tools/uwu" do
    erb :uwu
end
get "/tools/crytyper" do
    erb :crytyper
end
get "/tools/css-streamliner" do
    erb :cssstreamline
end
get "/blog" do
    @isadmin=session[:uid]==adminuid
    @entries=conn.exec("SELECT * FROM Blog;")
    erb :blog
end
get "/blog/edit" do
    if session[:uid]==adminuid
        @entry=conn.exec("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
        erb :blogedit
    end
end 
post "/blog/edit" do
    if session[:uid]==adminuid
        puts params[:content].gsub("'","''")
        result=conn.exec("UPDATE Blog SET content='#{params[:content].gsub("'","''")}' WHERE id=#{params[:id].to_i};")
        redirect "/blog"
    end
end
get "/blog/delete" do
    if session[:uid]==adminuid
        result=conn.exec("DELETE FROM Blog WHERE id=#{params["id"]};")
        redirect "/blog"
    end
end 
get "/blog/add" do
    if session[:uid]==adminuid
        erb :blogadd
    end
end
post "/blog/add" do
    if session[:uid]==adminuid
        puts params[:content].gsub("'","''")
        result=conn.exec("INSERT INTO Blog(id, date, title, content) VALUES (#{getindex(conn)+1}, TIMESTAMP \'#{conn.exec("SELECT NOW();")[0]["now"]}\', \'#{params[:title]}\', \'#{params[:content].gsub("'","''")}\');")
        redirect "/blog"
    end
end
get "/blog/:id" do
    redirect "/blog/#{params[:id]}/#{url_encode(conn.exec("SELECT title FROM Blog WHERE id=#{params[:id]};")[0]["title"])}"
end
get "/blog/:id/:name" do
    @isadmin=session[:uid]==adminuid
    @entry=conn.exec("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
    erb :blogpost
end
get "/admin" do
    if session[:uid]==adminuid
        erb :admin
    else
        redirect "/"
    end
end
get "/admin/todo" do
    if session[:uid]==adminuid
        @entries=conn.exec("SELECT * FROM TodoList;")
        erb :todo
    else
        redirect "/"
    end
end
post "/admin/todo" do
    if session[:uid]==adminuid
        result=conn.exec("INSERT INTO TodoList(task, color, notes, importance, notif) VALUES (\'#{params[:task].gsub("'","''")}\', \'#{params[:color]}\', \'#{params[:notes].gsub("'","''")}\', \'#{params[:importance].gsub("'","''")}\', \'#{params[:notif]}\');")
        redirect "/admin/todo"
    end
end
get "/todo/:id" do
    if session[:uid]==adminuid
        @entry=conn.exec("SELECT * FROM TodoList WHERE id=#{params[:id]};")[0]
        erb :todopost
    else
        redirect "/"
    end
end
post "/todo/:id" do
    if session[:uid]==adminuid
        result=conn.exec("UPDATE TodoList SET task='#{params[:task].gsub("'","''")}', color='#{params[:color]}', notes='#{params[:notes].gsub("'","''")}',importance='#{params[:importance].gsub("'","''")}',notif='#{params[:notif]}' WHERE id=#{params[:id].to_i};")
        redirect "/todo"
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
get "/sitemap.xml" do
    send_file "sitemap.xml"
end
get "/robots.txt" do
    send_file "robots.txt"
end
not_found do
    erb :"404"
end
def getindex(conn)
    highest=0
    conn.exec("SELECT id FROM Blog;").each do |entry|
        testhigh=entry["id"].to_i
        if testhigh>highest
            highest=testhigh
        end
    end
    return highest
end
def randword()
    Zip::File.open('public/words_alpha.zip') do |zip_file|
        entry = zip_file.glob('*.txt').first
        content = entry.get_input_stream.read 
        content.split("\n").sample
    end
end