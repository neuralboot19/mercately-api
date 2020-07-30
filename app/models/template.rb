class Template < ApplicationRecord
  belongs_to :retailer
  validates :title, presence: true

  has_one_attached :image

  after_create :generate_web_id

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }
  scope :for_messenger, -> { where(enable_for_messenger: true) }
  scope :for_whatsapp, -> { where(enable_for_whatsapp: true) }

  def to_param
    web_id
  end

  private

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
end
