class RetailerUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
  belongs_to :retailer
  has_many :agent_customers
  has_many :a_customers, class_name: 'Customer', source: :customer, through: :agent_customers
  has_many :mobile_tokens, dependent: :destroy
  has_many :agent_teams, dependent: :destroy
  has_many :team_assignments, through: :agent_teams
  has_many :templates, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :agent_notifications, dependent: :destroy
  has_many :deals

  validate :onboarding_status_format
  validates :agree_terms, presence: true
  validates :email, presence: true, uniqueness: true

  before_save :max_agents_limit
  before_save :set_only_assigned

  scope :all_customers, -> { where(only_assigned: false) }
  scope :only_assigned_customers, -> { where(only_assigned: true) }
  scope :active, -> (retailer_id) { where(retailer_id: retailer_id, removed_from_team: false, invitation_token: nil) }
  scope :active_and_pending_agents, -> (retailer_id) { where(retailer_id: retailer_id, removed_from_team: false) }
  scope :active_admins, lambda { |retailer_id|
    where(retailer_id: retailer_id, retailer_admin: true, removed_from_team: false, invitation_token: nil)
  }
  scope :active_agents, -> do
    where(retailer_admin: false, retailer_supervisor: false, removed_from_team: false, invitation_token: nil)
  end

  enum locale: %i[es en]

  accepts_nested_attributes_for :retailer

  attr_reader :raw_invitation_token

  def self.from_omniauth(auth, retailer_user, permissions, connection_type)
    retailer_user.update(provider: auth.provider, uid: auth.uid, facebook_access_token: auth.credentials.token)
    retailer_user.long_live_user_access_token

    retailer_user.handle_page_connection(messenger_integrated: true) if connect_messenger?(permissions, connection_type)
    retailer_user.handle_page_connection(instagram_integrated: true) if connect_instagram?(permissions, connection_type)
    retailer_user.handle_catalog_connection if connect_catalog?(permissions, connection_type)

    retailer_user
  end

  # TODO: mover a FacebookRetailer
  def handle_page_connection(messenger_integrated: false, instagram_integrated: false)
    facebook_retailer = FacebookRetailer.find_or_create_by(retailer_id: retailer.id)
    facebook_retailer.update!(
      uid: uid,
      access_token: facebook_access_token,
      messenger_integrated: facebook_retailer.messenger_integrated || messenger_integrated,
      instagram_integrated: facebook_retailer.instagram_integrated || instagram_integrated
    )

    facebook_service = Facebook::Api.new(facebook_retailer, self)
    facebook_service.update_retailer_access_token
    facebook_service.find_instagram_uid if facebook_retailer.instagram_integrated
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

  def supervisor?
    retailer_supervisor || false
  end

  def admin?
    retailer_admin || false
  end

  def agent?
    !retailer_admin && !retailer_supervisor
  end

  def customers
    Customer.joins("LEFT JOIN agent_customers ac ON ac.customer_id = customers.id")
      .where("(ac.retailer_user_id = ? OR ac.retailer_user_id is NULL) AND customers.retailer_id = ?", id, retailer_id)
  end

  def storage_id
    "#{id}_#{retailer_id}_#{email}"
  end

  def self.connect_messenger?(permissions, connection_type)
    permissions.any? { |p| p['permission'] == 'pages_manage_metadata' && p['status'] == 'granted' } &&
      connection_type == 'messenger'
  end

  def self.connect_instagram?(permissions, connection_type)
    permissions.any? { |p| p['permission'] == 'instagram_manage_messages' && p['status'] == 'granted' } &&
      connection_type == 'instagram'
  end

  def self.connect_catalog?(permissions, connection_type)
    permissions.any? { |p| p['permission'] == 'catalog_management' && p['status'] == 'granted' } &&
      connection_type == 'catalog'
  end

  def generate_api_token!(generate_device = false)
    new_token = SecureRandom.hex
    attrs = { api_session_token: new_token, api_session_expiration: 1.year.from_now }
    attrs[:api_session_device] = SecureRandom.hex(3) if generate_device || api_session_device.nil?
    update_attributes(attrs)

    new_token
  end

  def destroy_api_token!
    update(api_session_token: nil, api_session_expiration: nil)
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

    def set_only_assigned
      self.only_assigned = false unless agent?
    end

    def max_agents_limit
      return unless new_record? || (removed_from_team_changed? && removed_from_team == false)

      if RetailerUser.active_and_pending_agents(retailer_id).size >= retailer.max_agents
        errors.add(:base, 'Límite máximo de agentes alcanzado')
        throw(:abort)
      end
    end
end
