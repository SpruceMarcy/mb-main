require 'sinatra'
    set :bind, '0.0.0.0'

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