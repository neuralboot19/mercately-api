class GupshupPartner < ApplicationRecord
  validates_presence_of :name, :token

  def update_token
    return unless (Time.now - updated_at) / 3600 >= 20

    aux_token = GupshupPartners::Api.new.get_updated_token
    return unless aux_token.present?

    update(token: aux_token)
  end
end
