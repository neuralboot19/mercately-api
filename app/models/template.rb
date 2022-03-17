class Template < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :retailer_user, required: false
  has_one_attached :image
  has_many :additional_fast_answers, dependent: :destroy

  validate :correct_mime_type, if: -> { image.attached? }
  validates :title, presence: true

  before_save :set_file_type
  after_create :generate_web_id

  scope :for_questions, -> { where(enable_for_questions: true) }
  scope :for_chats, -> { where(enable_for_chats: true) }
  scope :for_messenger, -> { where(enable_for_messenger: true) }
  scope :for_whatsapp, -> { where(enable_for_whatsapp: true) }
  scope :for_instagram, -> { where(enable_for_instagram: true) }
  scope :owned, -> (creator_id, retailer_id) { where('retailer_user_id = ? OR ((global = TRUE OR retailer_user_id IS NULL) AND retailer_id = ?)', creator_id, retailer_id) }
  scope :owned_and_filtered, -> (search, creator_id) { where('title ILIKE ?' \
    ' OR answer ILIKE ?', "%#{search}%", "%#{search}%").where('retailer_user_id = ?' \
    ' OR retailer_user_id IS NULL OR global = ?', creator_id, true) }

  accepts_nested_attributes_for :additional_fast_answers, reject_if: :all_blank, allow_destroy: true

  def to_param
    web_id
  end

  private

    def correct_mime_type
      if enable_for_instagram && !image.content_type.in?(%w[image/jpg image/jpeg image/png])
        errors.add(:image, 'Solo imágenes')
      elsif !image.content_type.in?(%w[image/jpg image/jpeg image/png application/pdf])
        errors.add(:image, 'Solo imágenes o PDF')
      end
    end

    def set_file_type
      self.file_type = if image.attached?
                         if image.content_type.first(5) == 'image'
                           'image'
                         else
                           'file'
                         end
                       else
                         nil
                       end
    end
end
