class Message < ApplicationRecord
  after_create :broadcast
  def broadcast
    ActionCable.server.broadcast 'room_channel', content: self.content
  end
end
