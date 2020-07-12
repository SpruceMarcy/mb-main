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

  def circle
  end

  def matrix
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
  
  def wswsane
    require "WSWSANE"
    if !params["date"].nil? and params["date"] =~ /[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]/
      @neos=WSWSANE.get(ENV["NASA_API_KEY"],params["date"],params["date"])["near_earth_objects"].values[0].to_json
    else
      @neos=WSWSANE.getToday(ENV["NASA_API_KEY"])["near_earth_objects"].values[0].to_json
    end
  end
  
  def chatindex
    if session[:nickname].nil?
      @chats=nil
    else
      @chats=[]
      @counts=Hash.new
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if !hmessage["chat"].nil? && !(@chats.include? hmessage["chat"])
            if hmessage["chat"]!="config"
              if getperms(hmessage["chat"]).has_key?(session[:nickname])
                @chats << hmessage["chat"]
              end
            end
          end
          @counts[hmessage["chat"]]=(@counts[hmessage["chat"]]||0)+1
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      @players=getplayers()
      @chats=@chats-@players
      if @chats==[]
        @chats=nil
      end
    end
    session[:receipts]=session[:receipts]||Hash.new
    render layout: "chat"
  end

  def chatsetnickname
    if params[:nickname] =~ /^\w*$/
      newname=params[:nickname]
      Message.all.each do |message|
        begin
          hauth=JSON.parse(message.content)["author"]
          if hauth.downcase==newname.downcase
            newname=hauth
            break
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      session[:nickname]=newname
      content=Hash.new
      content["type"]="signup"
      content["author"]=newname
      content["chat"]="config"
      @m=Message.create(content: content.to_json)
    end
    redirect_to("/tools/chat")
  end
  def chatnew
    if params[:name] =~ /^\w*$/
      content=Hash.new
      content["type"]="create"
      content["author"]="Umpire"
      content["chat"]=params[:name]
      @m=Message.create(content: content.to_json)
    end
    redirect_to("/tools/chat/umpire")
  end
  def chat
    if !getperms(params[:roomno]).has_key?(session[:nickname])
      redirect_to("/tools/chat") and return
    end
    @messages=[]
    Message.all.order(:id).each do |message|
      begin
        @messages << JSON.parse(message.content)
      rescue JSON::ParserError => e
        delmsg(message)
      end
    end
    @message=Message.new
    @here=getperms(params[:roomno])
    @mutelist=getmutes(params[:roomno])
    @canwhisper=getwhiss(params[:roomno]).has_key?(session[:nickname])
    @dead=getdead()
    @players=getplayers()
    counter=0
    @messages.each do |mess|
      if mess["chat"]==params[:roomno]
        counter+=1
      end
    end
    session[:receipts]=session[:receipts]||Hash.new
    session[:receipts][params[:roomno]]=counter
    render layout: "chat"
  end
  def chatumpire
    @players=getplayers()
    @chats=[]
    Message.all.each do |message|
      begin
        hmessage=JSON.parse(message.content)
        if !hmessage["chat"].nil? && !(@chats.include? hmessage["chat"])
          if hmessage["chat"]!="config"
            @chats << hmessage["chat"]
          end
        end
      rescue JSON::ParserError => e
        delmsg(message)
      end
    end
    @chats=@chats-@players
    @perms=Hash.new
    @chats.each do |chat|
      @perms[chat]=getperms(chat)
    end
    @mutes=Hash.new
    @chats.each do |chat|
      @mutes[chat]=getmutes(chat)
    end
    @whiss=Hash.new
    @chats.each do |chat|
      @whiss[chat]=getwhiss(chat)
    end
    @dead=getdead()
    render layout: "chat"
  end
  def chatperm
    typestring=params[:permtype]
    content=Hash.new
    if typestring=="dead"
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]==typestring
            delmsg(message)
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      content["type"]=typestring
      content["author"]="Umpire"
      content["chat"]="config"
      content["perm"]=params[:perm] || Hash.new
    else
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]==typestring
            if hmessage["chat"]==params[:chat]
              delmsg(message)
            end
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      content["type"]=typestring
      content["author"]="Umpire"
      content["chat"]=params[:chat]
      content["perm"]=params[:perm] || Hash.new
    end
    @m=Message.create(content: content.to_json)
    redirect_to("/tools/chat/umpire")
  end
  private
    def getperms(chat)
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]=="perm"
            if hmessage["chat"]==chat
              return hmessage["perm"] || Hash.new
            end
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      returnval=Hash.new
      if getplayers().include?(chat)
        returnval[chat]="on"
        returnval["Umpire"]="on"
      end
      return returnval
    end
    def getmutes(chat)
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]=="mute"
            if hmessage["chat"]==chat
              return hmessage["perm"] || Hash.new
            end
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      return Hash.new
    end
    def getwhiss(chat)
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]=="whis"
            if hmessage["chat"]==chat
              return hmessage["perm"] || Hash.new
            end
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      return Hash.new
    end
    def getdead()
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if hmessage["type"]=="dead"
            return hmessage["perm"] || Hash.new
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      return Hash.new
    end
    def delmsg(message)
      message.delete
    end
    def getplayers()
      @players=[]
      Message.all.each do |message|
        begin
          hmessage=JSON.parse(message.content)
          if !hmessage["author"].nil? && !(@players.include? hmessage["author"])
            @players << hmessage["author"]
          end
        rescue JSON::ParserError => e
          delmsg(message)
        end
      end
      return @players
    end
end
