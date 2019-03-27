require 'sinatra'
    set :bind, '0.0.0.0'

get "/" do
    erb :index
end
get "/projects" do
    "project homepage"
end
get "/projects/" do
    "project directory"
end