class Template < ApplicationRecord
  belongs_to :retailer
  validates :title, :answer, presence: true

  after_create :generate_web_id

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }

  def to_param
    web_id
  end

  private

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
end
