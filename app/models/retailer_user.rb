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

  def self.from_omniauth(auth)
    retailer_user = find_by(email: auth.info.email)
    if retailer_user.nil?
      retailer_user = create_from_omniauth(auth)
    elsif (retailer_user.uid.blank? && retailer_user.provider.blank?) || retailer_user.facebook_access_token.nil?
      retailer_user.update(provider: auth.provider, uid: auth.uid, facebook_access_token: auth.credentials.token)
    end
    retailer_user.save_facebook_token
    retailer_user
  end

  def self.create_from_omniauth(auth)
    retailer = Retailer.create(name: auth.info.name)
    FacebookRetailer.create(uid: auth.uid, retailer: retailer, access_token: auth.credentials.token)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |retailer_user|
      retailer_user.email = auth.info.email
      retailer_user.password = Devise.friendly_token[0, 20]
      retailer_user.retailer = retailer
      retailer_user.facebook_access_token = auth.credentials.token
    end
  end

  def save_facebook_token
    facebook_retailer = retailer.facebook_retailer
    if facebook_retailer
      # TODO manejar errores del response de facebook
      facebook_service = Facebook::Api.new(facebook_retailer, self)
      response = facebook_service.get_long_live_user_access_token
      if response['expires_in']
        update(facebook_access_token: response['access_token'],
               facebook_access_token_expiration: Time.now + response['expires_in'].seconds)
      else
        update(facebook_access_token: response['access_token'])
      end
      facebook_service.update_retailer_access_token
    end
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
