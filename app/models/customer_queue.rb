class CustomerQueue
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :message_queues, dependent: :destroy

  field :retailer_id, type: Integer
  field :source, type: String
  field :payload, type: Hash

  index({ retailer_id: 1, source: 1 }, { unique: true })

  after_create :create_message_queue
  after_create :create_customer

  private

    def create_message_queue
      message_queues.create(payload: payload)
    end

    def create_customer
      retailer = Retailer.find_by(id: retailer_id)
      Whatsapp::Gupshup::V1::Helpers::Customers.create_customer(retailer, payload)
    end
end
