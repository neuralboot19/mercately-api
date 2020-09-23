class Template < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :retailer_user, required: false
  validates :title, presence: true

  has_one_attached :image

  after_create :generate_web_id

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }
  scope :for_messenger, -> { where(enable_for_messenger: true) }
  scope :for_whatsapp, -> { where(enable_for_whatsapp: true) }
  scope :owned, -> (creator_id) { where('retailer_user_id = ? OR retailer_user_id IS NULL', creator_id) }
  scope :owned_and_filtered, -> (search, creator_id) { where('title ILIKE ?' \
    ' OR answer ILIKE ?', "%#{search}%", "%#{search}%").where('retailer_user_id = ?' \
    ' OR retailer_user_id IS NULL OR global = ?', creator_id, true) }

  def to_param
    web_id
  end
end
