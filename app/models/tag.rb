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

  def to_param
    web_id
  end

  private

    def update_hs_fields
      retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: saved_change_to_tag.first).each do |chf|
        chf.update(customer_field: tag)
      end
    end

    def remove_mapped_fields
      retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: tag).destroy_all
    end
end
