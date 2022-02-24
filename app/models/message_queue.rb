class MessageQueue
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :customer_queue, index: true

  field :payload, type: Hash
  field :processed, type: Boolean, default: false

  before_destroy :create_message

  private

    def create_message
      return if processed

      retailer = Retailer.find_by(id: customer_queue.retailer_id)
      return unless retailer.present?

      customer = retailer.customers.find_by(phone: customer_queue.source)
      Whatsapp::Gupshup::V1::EventHandler.new(retailer, customer).process_queue_message!(self)
    end
end
