# This migration comes from raix (originally 20230625155300)
class CreateRaixChatMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :raix_chat_messages do |t|
      t.references :messageable, polymorphic: true, null: false
      t.string :role, null: false
      t.text :content, null: false
      t.integer :tokens, null: false, default: 0
      t.timestamps
    end
  end
end