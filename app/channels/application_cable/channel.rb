module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
      stream_from "channel"
    end
    def recieve(data)
      ActionCable.server.broadcast("channel",message: "YOLO")
    end
  end
end
