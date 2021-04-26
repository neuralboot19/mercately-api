class ContactGroup < ApplicationRecord
  include WebIdGenerateableConcern
  include ImportContactGroupsConcern

  belongs_to :retailer
  has_many :contact_group_customers
  has_many :customers, through: :contact_group_customers, dependent: :destroy
  has_many :campaigns

  validate :check_customers, unless: :imported
  validates_presence_of :name

  after_create :generate_web_id
  after_update :cancel_campaigns, if: :archived

  scope :not_archived, -> { where(archived: false) }

  def to_param
    web_id
  end

  def archived!
    update(archived: true)
  end

  private

    def check_customers
      return if customer_ids.present?

      errors.add(:customer_ids, 'Debe agregar clientes')
    end

    def cancel_campaigns
      campaigns.pending.update_all(status: :cancelled)
    end
end
