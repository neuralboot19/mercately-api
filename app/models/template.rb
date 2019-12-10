class Template < ApplicationRecord
  belongs_to :retailer
  validates :title, :answer, presence: true

  after_create :generate_web_id

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }

  private

    def generate_web_id
      self.web_id = retailer.web_id + id.to_s
    end
end
