class AgentCustomer < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :customer
  belongs_to :team_assignment, required: false

  before_destroy :agent_data
  before_update :agent_data, if: :will_save_change_to_retailer_user_id?
  after_destroy :free_spot_on_destroy
  after_update :free_spot_on_change, if: :saved_change_to_retailer_user_id?
  after_commit :send_push_notification, on: [:create, :update]

  scope :update_range_between, -> (start_date, end_date) { where(updated_at: start_date..end_date) }

  private

    def send_push_notification
      tokens = if retailer_user.android?
                  retailer_user.mobile_tokens
                  .pluck(:mobile_push_token)
                  .compact
                else
                  [retailer_user.email]
                end

      # It is suposed that tokens should be an empty array
      # if not found any mobile push token, anyway, I rather
      # to validate this before trying to send the notification
      return true if tokens.blank?

      body = "Nuevo chat asignado - #{customer_name}"
      channel = if customer.ws_active
                  'whatsapp'
                elsif customer.instagram?
                  'instagram'
                else
                  'messenger'
                end
      if retailer_user.android?
        Retailers::MobilePushNotificationJob.perform_later(tokens, body, customer.id, channel)
      else
        push_notification = OneSignalPushNotification.new(tokens, body, customer.id, channel)
        push_notification.send_messages
      end
    end

    def customer_name
      customer.full_names.blank? ? customer.phone : customer.full_names
    end

    def agent_data
      @agent_data = self
      @team_assignment_id_was = team_assignment_id_was
      @retailer_user_id_was = retailer_user_id_was
    end

    def free_spot_on_destroy
      return if @agent_data.team_assignment_id.blank?

      update_agent_team('destroy') unless not_update_agent?(@agent_data.customer)
    end

    def free_spot_on_change
      return if team_assignment_id.blank?

      update_agent_team('update') unless not_update_agent?(customer)
      update_column(:team_assignment_id, nil)
    end

    def update_agent_team(action)
      if action == 'destroy'
        team_id = @agent_data.team_assignment_id
        ret_user_id = @agent_data.retailer_user_id
      elsif action == 'update'
        team_id = @team_assignment_id_was
        ret_user_id = @retailer_user_id_was
      end

      agent_team = AgentTeam.where(team_assignment_id: team_id, retailer_user_id: ret_user_id).first
      agent_team&.update(assigned_amount: agent_team.assigned_amount - 1)
    end

    def not_update_agent?(customer)
      return customer.messenger_answered_by_agent? if customer.facebook_messages.first

      customer.whatsapp_answered_by_agent?
    end
end
