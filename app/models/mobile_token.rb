class MobileToken < ApplicationRecord
  attr_encrypted :token,
                 key: ENV['SECRET_KEY_BASE'],
                 mode: :per_attribute_iv_and_salt

  belongs_to :retailer_user

  validates :retailer_user, presence: true

  scope :expired, -> { where('expiration < ?', Time.now) }
  scope :active, -> { where('expiration > ?', Time.now) }

  before_create :set_device
  after_create :clean_expired

  def generate!
    new_token = SecureRandom.hex
    update_attributes(token: new_token, expiration: 1.week.from_now)

    new_token
  end

  private

    def set_device
      self.device = SecureRandom.hex(3)
    end

    def clean_expired
      MobileToken.expired.destroy_all unless Rails.env == 'test'
    end
end
