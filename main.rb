require 'net/smtp'
require 'base64'
require 'zip'
require 'httparty'
require 'ImageResize'
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

include ERB::Util

enable :sessions
set :session_secret, 'key goes here'

puts `mkdir imgcache`
imgcachelog=Hash.new

get '*' do
    @isadmin=session[:uid]==adminuid
    if !session[:style].nil? then
        @maincss=session[:style]
    else
        @maincss="main"
    end
    pass
end
post '*' do
    @adminstyle=false
    @isadmin=session[:uid]==adminuid
    if !session[:style].nil? then
        @maincss=session[:style]
    else
        @maincss="main"
    end
    pass
end


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
    @entry=query("SELECT * FROM Blog WHERE id=#{getindex()};")[0]
    erb :index
end
get "/tools/abc" do
   redirect "https://www.youtube.com/watch?v=j9jbdgZidu8" 
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
    erb :settings
end
post "/tools/settings/session/debug" do
    session[:debug]=!params[:debug].nil?
    redirect "/tools/settings"
end
post "/tools/settings/session/dyslexic" do
    session[:dyslexic]=!params[:dyslexic].nil?
    redirect "/tools/settings"
end
post "/tools/settings/session/style" do
    session[:style]=params[:selected]
    redirect "/tools/settings"
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
get "/tools/dither" do
    erb :dither
end
get "/tools/lavalamp" do
    erb :lavalamp
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
get "/tools/sarcasm" do
    erb :sarcasm
end
get "/tools/css-streamliner" do
    erb :cssstreamline
end
get "/photography" do
    @photos=query("SELECT id, title, date FROM photos;").values
    erb :photography
end
get "/blog" do
    @entries=query("SELECT * FROM Blog;")
    erb :blog
end
get "/blog/edit" do
    if session[:uid]==adminuid
        @entry=query("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
        erb :blogedit
    else
        status 404
    end
end 
post "/blog/edit" do
    if session[:uid]==adminuid
        puts params[:content].gsub("'","''")
        result=query("UPDATE Blog SET content='#{params[:content].gsub("'","''")}' WHERE id=#{params[:id].to_i};")
        redirect "/blog"
    else
        status 404
    end
end
get "/blog/delete" do
    if session[:uid]==adminuid
        result=query("DELETE FROM Blog WHERE id=#{params["id"]};")
        redirect "/blog"
    else
        status 404
    end
end 
get "/blog/add" do
    if session[:uid]==adminuid
        erb :blogadd
    else
        status 404
    end
end
post "/blog/add" do
    if session[:uid]==adminuid
        puts params[:content].gsub("'","''")
        result=query("INSERT INTO Blog(id, date, title, content) VALUES (#{getindex()+1}, TIMESTAMP \'#{query("SELECT NOW();")[0]["now"]}\', \'#{params[:title]}\', \'#{params[:content].gsub("'","''")}\');")
        redirect "/blog"
    else
        status 404
    end
end
get "/blog/:id" do
    redirect "/blog/#{params[:id]}/#{url_encode(query("SELECT title FROM Blog WHERE id=#{params[:id]};")[0]["title"])}"
end
get "/blog/:id/:name" do
    @entry=query("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
    erb :blogpost
end
get "/admin*" do
    if session[:uid]==adminuid
        @adminstyle=true
        pass
    else
        status 404
    end
end
post "/admin*" do
    if session[:uid]==adminuid
        @adminstyle=true
        pass
    else
        status 404
    end
end
get "/admin" do
    erb :admin
end
get "/admin/database" do
    @entries=getTables()
    erb :database
end
post "/admin/database" do
    @entries=getTables()
    @result=query(params["input"])
    erb :database
end
get "/admin/todo" do
    @entries=query("SELECT * FROM TodoList;")
    erb :todo
end
post "/admin/todo" do
    result=query("INSERT INTO TodoList(task, color, notes, importance, notif) VALUES (\'#{params[:task].gsub("'","''")}\', \'#{params[:color]}\', \'#{params[:notes].gsub("'","''")}\', \'#{params[:importance].gsub("'","''")}\', \'#{params[:notif]}\');")
    redirect "/admin/todo"
end
get "/admin/todo/:id" do
    @entry=query("SELECT * FROM TodoList WHERE id=#{params[:id]};")[0]
    erb :todopost
end
post "/admin/todo/:id" do
    if !params["setstatus"].nil? then
        result=query("UPDATE TodoList SET status='#{params["setstatus"]}' WHERE id=#{params[:id].to_i};")
    else
        result=query("UPDATE TodoList SET task='#{params[:task].gsub("'","''")}', color='#{params[:color]}', notes='#{params[:notes].gsub("'","''")}',importance='#{params[:importance].gsub("'","''")}',notif='#{params[:notif]}' WHERE id=#{params[:id].to_i};")
    end
    redirect "/admin/todo"
end   
get "/admin/photoview/:id.jpg" do
    erb :photoview
end
get "/admin/photoupload" do
    erb :photoupload
end
post "/admin/photoupload" do
    testr = params[:photo][:tempfile].read
    f = File.open('tempi.jpg', 'wb')
    f.write(testr)
    f.close()
    puts Base64.encode64(testr)
    result=query("INSERT INTO photos(title,photo) VALUES (\'TempFile\',decode(encode($1,'escape'),'escape'));",[Base64.encode64(testr)])
    erb :photoupload
end
get "/photo/:id.jpg" do
    imgcachebalance(imgcachelog)
    cachename="img#{params[:id]}-#{params[:width]}-0.jpg"
    if File.file?("imgcache/#{cachename}")
        imgcheckout(imgcachelog,cachename)
        send_file "imgcache/#{cachename}"
    end
    if query("SELECT count(id) FROM photos WHERE id = #{params[:id]};")[0]["count"].to_i>0
        test = query("SELECT encode(photo,'escape') FROM photos WHERE id=#{params[:id]};")[0]["encode"]
        f = File.open('imgcache/temp.jpg', 'wb')
        f.write(Base64.decode64(test.to_s))
        f.close()
        if !params[:width].nil?
            Image.resize("#{__dir__}/imgcache/temp.jpg", "#{__dir__}/imgcache/#{cachename}", params[:width], 0)
            imgcheckout(imgcachelog,cachename)
            send_file "imgcache/#{cachename}"
        else
            send_file 'imgcache/temp.jpg'
        end
    else
        status 404
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
        message=params[:browser]+"\n"+message
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
def getindex()
    highest=0
    query("SELECT id FROM Blog;").each do |entry|
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
def getTables()
    returnval=Hash.new
    query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;").each do |table_name|
        returnval[table_name["table_name"]]=query("SELECT * FROM #{table_name["table_name"]};")
    end
    return returnval
end
def query(q)
    conndomain=ENV["data_dom"]
    connport=ENV["data_port"].to_i
    conndata=ENV["data_data"]
    connuser=ENV["data_user"]
    connpass=ENV["data_pass"]
    conn=PG.connect(conndomain, connport,"","",conndata, connuser, connpass)
    returnval = conn.exec(q)
    conn.finish
    return returnval
end
def imgcheckout(imgcachelog,filename)
    if !imgcachelog.key?(filename)
        imgcachelog[filename]=0
    else
        imgcachelog[filename]+=1
    end
end
def imgcachebalance(imgcachelog)
    while `du -s imgcache`.to_i>256000 do
        if imgcachelog.length>0 then
            delfilename=imgcachelog.sort{|a,b| a[1] <=> b[1]}[0][0]
            puts "deleting imgcache/#{delfilename}"
            puts `rm imgcache/#{delfilename}`
            imgcachelog.delete(delfilename)
        else
            puts "!!!!!clearing cache!!!!!"
            puts `rm imgcache/*`
        end
    end
end