class Deal < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :funnel_step
  belongs_to :customer, optional: true
  belongs_to :retailer_user

  validates :name, presence: true

  before_update :save_previous_values
  after_create :position!
  after_create :generate_web_id
  after_create :validate_customer_deals
  after_update :reposition!
  after_destroy :validate_customer_deals
  after_destroy :reposition_deals!

  scope :by_search_text, -> (value) {
    left_joins(:customer)
    .where("name ILIKE :search OR first_name ILIKE :search OR last_name ILIKE :search OR email ILIKE :search OR phone ILIKE :search",
    search: "%#{value}%")
  }

  scope :filter_by_agent, -> (retailer_user) {
    if retailer_user.admin? || retailer_user.supervisor?
      all
    else
      where(retailer_user_id: retailer_user)
    end
  }

  attr_accessor :previous_position
  attr_accessor :previous_funnel_step_id

  delegate :currency_symbol, to: :retailer

  PAGINATES_PER = 25

  paginates_per PAGINATES_PER

  #TODO ADD SPECS
  private

    def validate_customer_deals
      return unless customer

      if customer.deals.exists?
        customer.update_columns(has_deals: true)
      else
        customer.update_columns(has_deals: false)
      end
    end

    def save_previous_values
      self.previous_position = position_was
      self.previous_funnel_step_id = funnel_step_id_was
    end

    def position!
      funnel_step.deals.where.not(id: id).update_all('position = position + 1')
    end

    def reposition!
      if funnel_step_id == previous_funnel_step_id
        reposition_same_funnel_step
      else
        reposition_other_funnel_step
      end
    end

    def reposition_same_funnel_step
      if position < previous_position
        range = position..previous_position
        deals = funnel_step.deals.where.not(id: id).where(position: range)
        deals.update_all('position = position + 1')
      else
        range = previous_position..position
        deals = funnel_step.deals.where.not(id: id).where(position: range)
        deals.update_all('position = position - 1')
      end
    end

    def reposition_other_funnel_step
      # Update step deals position
      max_position = funnel_step.deals.maximum(:position)
      range = position..max_position
      deals = funnel_step.deals.where.not(id: id).where(position: range)
      deals.update_all('position = position + 1')

      # Update previous step deals position
      previous_funnel_step = FunnelStep.find(previous_funnel_step_id)
      return if !previous_funnel_step.deals.exists?

      max_position = previous_funnel_step.deals.maximum(:position)
      range = previous_position..max_position
      deals = previous_funnel_step.deals.where(position: range)
      deals.update_all('position = position - 1')
    end

    def reposition_deals!
      return if !funnel_step.deals.exists?

      max_position = funnel_step.deals.maximum(:position)
      range = position..max_position
      deals = funnel_step.deals.where.not(id: id).where(position: range)
      deals.update_all('position = position - 1')
    end
end
