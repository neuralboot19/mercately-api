class ChangeInstagramMessagesDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :instagram_messages, :sent_from_mercately, false
    change_column_default :instagram_messages, :sent_by_retailer, false
    InstagramMessage.update_all(sent_by_retailer: false, sent_from_mercately: false)
  end

  def down
    change_column_default :instagram_messages, :sent_by_retailer, nil
    change_column_default :instagram_messages, :sent_from_mercately, nil
  end
end
