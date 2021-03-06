class MessagesController < ApplicationController
  def new
    @message = Message.new
  end
  def create
    if params[:type].nil?
      @message = Message.create(msg_params)
    elsif params[:type]=="message"
      if params["message"]["content"]=~/\\w/ or params["message"]["content"]=~/\\W/
        jmessage=Hash.new
        jmessage["type"]="whisper"
        removedcommand=params["message"]["content"].sub(/^\\w.*? /,"").sub(/^\\W.*? /,"")
        jmessage["recipient"]=removedcommand.split.first.sub("[","").sub("]","")
        jmessage["message"]=removedcommand.sub(/[^ ]+? /,"")
      else
        jmessage=Hash.new
        jmessage["type"]="message"
        jmessage["message"]=params["message"]["content"]
      end       
      jmessage["author"]=params["author"]
      jmessage["chat"]=params["chat"]
      Time.zone="London"
      jmessage["timestamp"]=Time.zone.now.strftime("%d/%m %H:%M")
      @message = Message.create(content: jmessage.to_json)
    end
    @message.save
  end

  private

  def msg_params
    params.require(:message).permit(:content)
  end
end

