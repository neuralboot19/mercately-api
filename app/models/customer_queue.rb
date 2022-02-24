class CustomerQueue
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :message_queues, dependent: :destroy

  field :retailer_id, type: Integer
  field :source, type: String
  field :payload, type: Hash
  field :retry_count, type: Integer, default: 0
  field :retry_customer_count, type: Integer, default: 0

  index({ retailer_id: 1, source: 1 }, { unique: true })

  after_create :create_message_queue
  after_create :create_customer

  def retry_process
    update(retry_count: retry_count + 1)
    if retry_count >= 3
      destroy_customer_queue
      return
    end

    create_customer
  end

  def retry_customer_process(customer)
    update(retry_customer_count: retry_customer_count + 1)
    if retry_customer_count >= 3
      destroy_customer_queue
      return
    end

    customer.retry_create_messages
  end

  private

    def create_message_queue
      message_queues.create(payload: payload)
    end

    def create_customer
      retailer = Retailer.find_by(id: retailer_id)
      Whatsapp::Gupshup::V1::Helpers::Customers.create_customer(self, retailer, payload)
    end

    def destroy_customer_queue
      message_queues.update_all(processed: true)
      reload.destroy
    end
end
