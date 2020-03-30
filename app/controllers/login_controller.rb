class LoginController < ApplicationController
  def login
    responseparams={}
    responseparams["client_id"]=ENV["consumer_key"]
    responseparams["redirect_uri"]="https://mxmbrook.co.uk/callback"
    redirect_to("https://github.com/login/oauth/authorize?#{responseparams.to_param}", status: 303)
  end  

  def callback
    accesstoken=HTTParty.post('https://github.com/login/oauth/access_token',:query => {
        :client_id=>ENV["consumer_key"],
        :client_secret=>ENV["consumer_secret"],
        :code=>params[:code],
        }, :headers=>{
        "Accept" => "application/json"
        })["access_token"]
    userinformation = HTTParty.get('https://api.github.com/user',:headers=>{
        "access_token" => accesstoken,
        })
    session[:uid]=userinformation["login"]
    session[:logo]=userinformation["avatar_url"]
    puts userinformation
    session[:logged_in]=true
    redirect_to("/")
  end

  def logout
    session[:uid] = nil
    session[:logo] = nil
    session[:logged_in] = false
    redirect_to('/')
  end
end
