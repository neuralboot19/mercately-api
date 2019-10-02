class Template < ApplicationRecord
  belongs_to :retailer
  validates :title, :answer, presence: true

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }
end
