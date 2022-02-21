class Tag < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :customer_tags, dependent: :destroy
  has_many :customers, through: :customer_tags, dependent: :destroy
  has_many :action_tags, dependent: :destroy
  has_many :chat_bot_actions, through: :action_tags

  validates :tag, presence: true

  after_create :generate_web_id
  after_update :update_hs_fields, if: :saved_change_to_tag?
  after_destroy :remove_mapped_fields

  before_save :generate_font_color, if: :will_save_change_to_tag_color?

  scope :find_tag, -> (value) { where('lower(tag) = ?', value.downcase) }

  def to_param
    web_id
  end

  private

    def update_hs_fields
      return unless retailer.hubspot_integrated?

      retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: saved_change_to_tag.first).each do |chf|
        chf.update(customer_field: tag)
      end
    rescue StandardError => e
      SlackError.send_error(e)
      HubspotService::Api.notify_broken_integration(retailer)
    end

    def remove_mapped_fields
      retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: tag).destroy_all
    end

    def generate_font_color
      if tag_color != '#ffffff00'
        colors = tag_color.match(/^#(..)(..)(..)$/).captures.map(&:hex)
        self.font_color = if (colors[0] * 0.299 + colors[1] * 0.587 + colors[2] * 0.114) > 186
                            '#000000'
                          else
                            '#FFFFFF'
                          end
      end
    end
end
