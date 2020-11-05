# frozen_string_literal: true

module StatsChatsConcern
  extend ActiveSupport::Concern

  def total_chats_answered
    total_chats_ws
    total_chats_answered_ws
    total_chats_msn
    total_chats_answered_msn

    @total_chats = [
      {
        platform: 'Whatsapp',
        total_chats: @total_ws,
        total_answered: @total_answered_ws,
        total_not_answered: @total_ws - @total_answered_ws
      },
      {
        platform: 'Messenger',
        total_chats: @total_msn,
        total_answered: @total_answered_msn,
        total_not_answered: @total_msn - @total_answered_msn
      },
      {
        platform: 'TOTAL',
        total_chats: @total_ws + @total_msn,
        total_answered: @total_answered_ws + @total_answered_msn,
        total_not_answered: (@total_ws - @total_answered_ws) + (@total_msn - @total_answered_msn)
      }
    ]
  end

  private

    def total_chats_ws
      @total_ws = 0
      return unless current_retailer.whatsapp_integrated?

      @total_ws = @total_agent_chats_assigned_ws.values.sum
    end

    def total_chats_answered_ws
      @total_answered_ws = 0
      return unless current_retailer.whatsapp_integrated?

      @total_answered_ws = @total_agent_chats_answered_ws.values.sum
    end

    def total_chats_msn
      @total_msn = 0
      return unless current_retailer.facebook_retailer&.connected?

      @total_msn = @total_agent_chats_assigned_msn.values.sum
    end

    def total_chats_answered_msn
      @total_answered_msn = 0
      return unless current_retailer.facebook_retailer&.connected?

      @total_answered_msn = @total_agent_chats_answered_msn.values.sum
    end
end
