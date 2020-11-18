class OptionSubList < ApplicationRecord
  belongs_to :chat_bot_option

  before_create :set_position
  after_destroy :reassign_positions

  private

    def set_position
      self.position = self.chat_bot_option.option_sub_lists.count + 1
    end

    def reassign_positions
      self.chat_bot_option.option_sub_lists.order(:id).except(self).each_with_index do |osl, index|
        osl.update_column(:position, index + 1)
      end
    end
end
