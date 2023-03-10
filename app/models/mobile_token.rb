class MobileToken < ApplicationRecord
  attr_encrypted :token,
                 key: ENV['SECRET_KEY_BASE'],
                 mode: :per_attribute_iv_and_salt

  belongs_to :retailer_user

  validates :retailer_user, presence: true

  before_create :set_device

  def generate!
    new_token = SecureRandom.hex
    update_attributes(token: new_token)

    new_token
  end

  private

    def set_device
      self.device = SecureRandom.hex(3)
    end
end
