# frozen_string_literal: true

class Order < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :customer
  belongs_to :retailer_user, required: false
  belongs_to :sales_channel, required: false
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  has_many :messages

  validates :feedback_message, length: { maximum: 160 }, if: :feedback_message?

  before_save :set_positive_rating, if: :will_save_change_to_status?
  before_update :set_old_status, if: :will_save_change_to_status?
  after_update :adjust_ml_stock, if: :saved_change_to_status?
  after_create :generate_web_id

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

  enum status: %i[pending success cancelled]
  enum merc_status: %i[
    confirmed
    payment_required
    payment_in_process
    partially_paid
    paid
    cancelled
    invalid_order
  ], _prefix: true
  enum feedback_reason: %i[SELLER_OUT_OF_STOCK SELLER_DIDNT_TRY_TO_CONTACT_BUYER BUYER_NOT_ENOUGH_MONEY BUYER_REGRETS]
  enum feedback_rating: %i[positive negative neutral]

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :customer, reject_if: :all_blank, allow_destroy: false

  delegate :retailer_id, :retailer, to: :customer

  def self.retailer_orders(retailer_id, status)
    orders = preload(:customer, :order_items).joins(:customer).where('customers.retailer_id = ?', retailer_id)
    orders = orders.where(status: status) if status != 'all'
    orders
  end

  def total
    order_items.map { |order_item| order_item.unit_price * order_item.quantity }.sum
  end

  def last_message
    return @last_message unless @last_message.blank? || @last_message.order_id != id

    @last_message = messages.order(created_at: 'DESC').first
  end

  def unread_message?
    messages.where(answer: nil).last&.date_read.blank?
  end

  def last_message_received_date
    messages.where(answer: nil).last&.created_at
  end

  def to_param
    web_id
  end

  private

    def adjust_ml_stock
      if from_pending_to_cancelled?
        update_items
        push_feedback if feedback_reason.present?
      elsif from_pending_to_success?
        push_feedback
      elsif from_success_to_cancelled?
        update_items
      end
    end

    def push_feedback
      return unless meli_order_id.present?

      MercadoLibre::Orders.new(retailer).push_feedback(self)
    end

    def set_positive_rating
      self.feedback_rating = 'positive' if status == 'success' && meli_order_id
    end

    # Al cancelarse una orden se repone o se devuelve el stock apartado cuando se creo la misma
    # Si la orden estaba exitosa, se actualiza el stock tambien en ML
    def update_items
      order_items.each do |order_item|
        product = order_item.product
        product_variation = order_item.product_variation

        if product_variation.present?
          data = product_variation.data
          new_sold_quantity = data['sold_quantity'].to_i - order_item.quantity
          new_available_quantity = data['available_quantity'].to_i + order_item.quantity

          data['sold_quantity'] = new_sold_quantity
          data['available_quantity'] = new_available_quantity if change_available_quantity(order_item)

          product_variation.update(data: data)
          product.update_variations_quantities
        else
          new_sold_quantity = product.sold_quantity.to_i - order_item.quantity
          new_available_quantity = product.available_quantity + order_item.quantity

          product.update(available_quantity: new_available_quantity) if change_available_quantity(order_item)
          product.update(sold_quantity: new_sold_quantity)
        end

        update_ml(product) if from_success_to_cancelled?
        product.update_status_publishment(true)
      end
    end

    def update_ml(product)
      return unless product.meli_product_id.present?

      p_ml(product).push_update(product)
      product.upload_variations_to_ml if product.product_variations.present?
    end

    def p_ml(product)
      @p_ml ||= MercadoLibre::Products.new(product.retailer)
    end

    def change_available_quantity(order_item)
      !order_item.from_ml? || order_item.product.meli_status == 'closed' ||
        from_success_to_cancelled?
    end

    def from_pending_to_cancelled?
      @status_was == 'pending' && status == 'cancelled'
    end

    def from_pending_to_success?
      @status_was == 'pending' && status == 'success'
    end

    def from_success_to_cancelled?
      @status_was == 'success' && status == 'cancelled'
    end

    def set_old_status
      @status_was = status_was
    end
end
