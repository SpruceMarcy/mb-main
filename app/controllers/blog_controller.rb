require "erb"
include ERB::Util
class BlogController < ApplicationController
  def index
    @entries=query("SELECT * FROM Blog ORDER BY id DESC;")
  end

  def edit
    if session[:uid]==@adminuid
      @entry=query("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
    else
      redirect_to("/404",status: 404)
    end
  end

  def submitedit
    if session[:uid]==@adminuid
      puts params[:content].gsub("'","''")
      result=query("UPDATE Blog SET content='#{params[:content].gsub("'","''")}' WHERE id=#{params[:id].to_i};")
      redirect_to("/blog")
    else
      redirect_to("/404",status: 404)
    end
  end

  def delete
    if session[:uid]==@adminuid
      result=query("DELETE FROM Blog WHERE id=#{params["id"]};")
      redirect_to("/blog")
    else
      redirect_to("/404",status: 404)
    end
  end

  def add
    puts "session"
    puts session[:uid]
    puts "adminuid"
    puts @adminuid
    if session[:uid]!=@adminuid
      redirect_to("/404",status: 404)
    end
  end

  def submitadd
    if session[:uid]==@adminuid
      result=query("INSERT INTO Blog(id, date, title, content) VALUES (#{getindex()+1}, TIMESTAMP \'#{query("SELECT NOW();")[0]["now"]}\', \'#{params[:title].gsub("'","''")}\', \'#{params[:content].gsub("'","''")}\');")
      redirect_to("/blog")
    else
      redirect_to("/404",status: 404)
    end
  end

  def show
    if params[:name].nil?
      redirect_to("/blog/#{params[:id]}/#{url_encode(query("SELECT title FROM Blog WHERE id=#{params[:id]};")[0]["title"]).gsub("%20","_")}")
    else
      @entry=query("SELECT * FROM Blog WHERE id=#{params[:id]};")[0]
    end
  end

  def aprilfools
    if params[:id]=="7"
      redirect_to("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    end
    if params[:id]=="6"
      redirect_to("https://www.youtube.com/watch?v=j9jbdgZidu8")
    end
    if params[:id]=="8"
      redirect_to("https://www.youtube.com/watch?v=E8gmARGvPlI")
    end
  end
end
