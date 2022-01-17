class AddStatisticsToRetailerUnfinishedMessageBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_unfinished_message_blocks, :statistics, :integer
  end
end
