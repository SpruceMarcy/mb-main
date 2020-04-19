class AddIdToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :id, :primary_key
  end
end
