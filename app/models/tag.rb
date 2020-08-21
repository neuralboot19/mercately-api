class Tag < ApplicationRecord
  include WebIdGenerateableConcern

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
end
