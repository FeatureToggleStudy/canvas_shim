class AddFieldsToConversationMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :conversation_messages, :author_id, :integer
    add_column :conversation_messages, :conversation_id, :integer
  end
end
