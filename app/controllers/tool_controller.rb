require 'zip'
require 'httparty'
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
end
