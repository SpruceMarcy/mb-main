class MessagesController < ApplicationController
  def new
    @message = Message.new
  end
  def create
    if params[:type].nil?
      @message = Message.create(msg_params)
    elsif params[:type]=="message"
      jmessage=Hash.new
      jmessage["type"]="message"
      jmessage["message"]=params["message"]["content"]
      jmessage["author"]=params["author"]
      jmessage["chat"]=params["chat"]
      @message = Message.create(content: jmessage.to_json)
    end
    if @message.save
      ActionCable.server.broadcast 'room_channel', content: @message.content
    end
  end

  private

  def msg_params
    params.require(:message).permit(:content)
  end
end

