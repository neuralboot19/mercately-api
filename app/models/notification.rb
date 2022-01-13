class Notification < ApplicationRecord
  has_many :retailer_user_notifications, class_name: 'RetailerUserNotification'
  has_many :retailer_users, through: :retailer_user_notifications
  has_many_attached :files

  validates :title, presence: true
  validate :min_visible_until

  after_commit :notify_users, on: :update, if: :saved_change_to_published?
  after_commit :remove_notification, on: :update, if: :saved_change_to_published?

  enum visible_for: %i[all admins admins_supervisors], _prefix: true

  def template_body(retailer = nil, retailer_user = nil)
    body.gsub!(/%retailer%/, retailer.name) if retailer
    return body if retailer_user.nil?

    body.gsub!(/%first_name%/, retailer_user.first_name)
    body.gsub!(/%last_name%/, retailer_user.last_name)
    body
  end

  private

    def min_visible_until
      return if visible_until.nil? || visible_until.change(offset: '-05:00') > Time.now

      errors.add(:visible_until, 'La fecha y hora deben ser posteriores a la hora actual')
    end

    def notify_users
      return unless published

      users_to_notify = case visible_for
                        when 'admins'
                          RetailerUser.select(:id).where(retailer_admin: true, removed_from_team: false, invitation_token: nil)
                        when 'admins_supervisors'
                          RetailerUser.select(:id).where('retailer_admin = TRUE OR retailer_supervisor = TRUE')
                            .where(removed_from_team: false, invitation_token: nil)
                        else
                          RetailerUser.select(:id).where(removed_from_team: false, invitation_token: nil)
                        end
      self.retailer_users << users_to_notify
      save
    end

    def remove_notification
      return if published

      retailer_user_notifications.destroy_all
    end
end
