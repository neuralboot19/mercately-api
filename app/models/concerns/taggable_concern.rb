module TaggableConcern
  extend ActiveSupport::Concern

  def available_customer_tags(customer_id = nil)
    return tags unless customer_id

    tags.where.not(id: CustomerTag.where(customer_id: customer_id).pluck(:tag_id))
  end
end
