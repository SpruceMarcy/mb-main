require 'zip'
require 'httparty'
require 'json'
class ToolController < ApplicationController
  def index
  end

  def settings
  end

  def wordrand
    @randword=""
    Zip::File.open(Rails.root.join('public','words_alpha.zip')) do |zip_file|
        entry = zip_file.glob('*.txt').first
        content = entry.get_input_stream.read 
        @randword=content.split("\n").sample
    end
  end

  def yourand
    randword=""
    Zip::File.open(Rails.root.join('public','words_alpha.zip')) do |zip_file|
        entry = zip_file.glob('*.txt').first
        content = entry.get_input_stream.read 
        randword=content.split("\n").sample
    end
    searchresults =HTTParty.get("https://www.googleapis.com/youtube/v3/search?key="+ENV["you_key"]+"&part=snippet&q="+randword)
    videos = searchresults["items"]
    videos.reverse.each do |video|
        if video["id"]["kind"]=="youtube#video"
             redirect_to("https://youtu.be/"+video["id"]["videoId"]) and return
        end
    end
  end

  def wordgen
    @randword=`java -jar "#{Rails.root.join('public','wordgen.jar')}" "#{Rails.root.join('public','words_alpha.txt')}"`
  end

  def redrand
    sub=["tihi","tili"].sample
    redditposts=HTTParty.get("https://www.reddit.com/r/#{sub}/top/.json?t=month",:headers => {"User-agent" =>"Top post getter for tihi/tili roulette"})
    if redditposts["message"].nil? then
        @redpost=redditposts["data"]["children"].sample
    else
        @redtext=redditposts["message"]
    end
  end

  def alpaca
  end

  def cells
  end

  def dither
  end

  def lavalamp
  end

  def soundvisualiser
  end

  def replayer
  end

  def vic
  end

  def bean
  end

  def uwu
  end

  def crytyper
  end

  def sarcasm
  end

  def cssStreamliner
  end

  def divCounter
    @hide=true
    if request.method=="GET"
      @errmessage=""
    elsif request.method=="POST"
      newsite=HTTParty.get(params["url"],headers=>{"User-Agent" => params["agent"]})
      if newsite.code==200
        @errmessage=""
        @hide=false
        divsearch=newsite.body.scan(/[ \t]*<div.*?>[ \t]*/)
        @divcount=divsearch.length.to_s
        @tagcount=(newsite.body.scan(/<.*?>/).length - newsite.body.scan(/<\/.*?>/).length).to_s
        @tagratio='%.2f' % (100.0*divsearch.length/@tagcount.to_i) + "%"
        @htmlsize="#{newsite.body.length.to_s} Bytes"
        divsize=0
        divsearch.each do |thisdiv|
          divsize+=thisdiv.length
        end
        @divsize="#{divsize} Bytes"
        @divratio='%.2f' % (100.0*divsize/newsite.body.length) + "%"
      else
        @errmessage="Error: #{newsite.code} #{newsite.message}"
      end
    end
  end

  def chatindex
    if session[:nickname].nil?
      @chats=nil
    else
      @chats=[]
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if !hmessage["chat"].nil? && !(@chats.include? hmessage["chat"])
            @chats << hmessage["chat"]
          end
        rescue JSON::ParserError => e
          message.delete
        end
      end
      if @chats==[]
        @chats=nil
      end
    end
  end

  def chatsetnickname
    if params[:nickname] =~ /^\w*$/
      session[:nickname]=params[:nickname]
    end
    redirect_to("/tools/chat")
  end
  def chatnew
    if params[:name] =~ /^\w*$/
      content=Hash.new
      content["type"]="create"
      content["author"]=session[:nickname]
      content["chat"]=params[:name]
      puts "YOOOOOOOOOOOOOOOOOOOOOOO"
      puts content
      @m=Message.create(content: content.to_json)
    end
    redirect_to("/tools/chat")
  end
  def chat
    @messages=[]
    Message.all.each do |message|
      begin
        @messages << JSON.parse(message.content)
      rescue JSON::ParserError => e
        message.delete
      end
    end
    @message=Message.new
  end
end
