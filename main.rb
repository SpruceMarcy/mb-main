require 'sinatra'

get "/" do
    erb :index
end
get "/projects" do
    "project homepage"
end
get "/projects/"
    "project directory"
end