class RetailerUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
  belongs_to :retailer
  has_many :agent_customers
  has_many :mobile_tokens, dependent: :destroy

  validate :onboarding_status_format
  validates :agree_terms, presence: true

  accepts_nested_attributes_for :retailer

  attr_reader :raw_invitation_token

  def self.from_omniauth(auth, retailer_user, permissions)
    retailer_user.update(provider: auth.provider, uid: auth.uid, facebook_access_token: auth.credentials.token)
    retailer_user.long_live_user_access_token

    retailer_user.handle_page_connection if
      permissions.any? { |p| p['permission'] == 'manage_pages' && p['status'] == 'granted' }

    retailer_user.handle_catalog_connection if
      permissions.any? { |p| p['permission'] == 'catalog_management' && p['status'] == 'granted' }

    retailer_user
  end

  # TODO: mover a FacebookRetailer
  def handle_page_connection
    facebook_retailer = FacebookRetailer.find_or_create_by(retailer_id: retailer.id)
    facebook_retailer.update!(uid: uid, access_token: facebook_access_token)

    facebook_service = Facebook::Api.new(facebook_retailer, self)
    facebook_service.update_retailer_access_token
  end

  def handle_catalog_connection
    FacebookCatalog.find_or_create_by(retailer_id: retailer.id)
  end

  def long_live_user_access_token
    # TODO: manejar errores del response de facebook
    facebook_service = Facebook::Api.new(nil, self)
    response = facebook_service.long_live_user_access_token
    self.facebook_access_token = response['access_token']
    self.facebook_access_token_expiration = Time.now + response['expires_in'].seconds if response['expires_in']
    save!
  end

  def active_for_authentication?
    super && !removed_from_team?
  end

  def inactive_message
    !removed_from_team? ? super : 'Tu cuenta no se encuentra activa'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    retailer_admin
  end

  def agent?
    !retailer_admin
  end

  def customers
    Customer.joins(:agent_customer).where('retailer_user_id = ?', id) +
      Customer.joins(:retailer).where.not(id: AgentCustomer.all.pluck(:customer_id)).where(retailer_id: retailer_id)
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
end
