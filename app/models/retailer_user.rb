class RetailerUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
  belongs_to :retailer

  validate :onboarding_status_format
  validates :agree_terms, presence: true
  after_create :send_welcome_email

  accepts_nested_attributes_for :retailer

  def self.from_omniauth(auth, retailer_user)
    retailer_user.update(provider: auth.provider, uid: auth.uid, facebook_access_token: auth.credentials.token)
    retailer_user.handle_page_connection
    retailer_user
  end

  # TODO mover a FacebookRetailer
  def handle_page_connection
    facebook_retailer = FacebookRetailer.create_with(
      uid: uid,
      access_token: facebook_access_token
    ).find_or_create_by(retailer_id: retailer.id)
    # TODO manejar errores del response de facebook
    facebook_service = Facebook::Api.new(facebook_retailer, self)
    response = facebook_service.get_long_live_user_access_token
    self.facebook_access_token = response['access_token']
    if response['expires_in']
      self.facebook_access_token_expiration = Time.now + response['expires_in'].seconds
    end
    save!
    facebook_service = Facebook::Api.new(facebook_retailer, self)
    facebook_service.update_retailer_access_token
    facebook_service.subscribe_page_to_webhooks
  end

  private

    def onboarding_status_format
      onboarding_status = self.onboarding_status.to_h.transform_keys(&:to_sym)

      unless %i[step skipped completed].all? { |key| onboarding_status.key?(key) }
        errors.add(:onboarding_status, 'error de validación')
      end

      unless (0..4).include?(onboarding_status[:step].to_i) &&
             [true, false].include?(ActiveModel::Type::Boolean.new.cast(onboarding_status[:skipped])) &&
             [true, false].include?(ActiveModel::Type::Boolean.new.cast(onboarding_status[:completed]))
        errors.add(:onboarding_status, 'valores invalidos')
      end
    end

    # Send email after create
    def send_welcome_email
      RetailerMailer.welcome(self).deliver_now if persisted?
    end
end
