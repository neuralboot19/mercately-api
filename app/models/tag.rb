class Tag < ApplicationRecord
  belongs_to :retailer
  has_many :customer_tags, dependent: :destroy
  has_many :customers, through: :customer_tags
  has_many :action_tags, dependent: :destroy
  has_many :chat_bot_actions, through: :action_tags

  validates :tag, presence: true

  after_create :generate_web_id

  def to_param
    web_id
  end

  private

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
end
