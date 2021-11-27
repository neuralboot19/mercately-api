module PaymentPlansControllerConcern
  extend ActiveSupport::Concern

  def used_whatsapp_messages
    whatsapp_messages = current_retailer.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
    messages = current_retailer.send(whatsapp_messages).range_between(@payment_plan.start_date, Time.now)

    total_conversations = messages.group_by_month(:created_at).conversation_messages
    total_notifications = messages.group_by_month(:created_at).notification_messages

    @count_conversations_by_cost = total_conversations.group(:cost).count
    @count_notifications_by_cost = total_notifications.group(:cost).count

    @total_conversations_by_cost = total_conversations.group(:cost).sum(:cost)
    @total_notifications_by_cost = total_notifications.group(:cost).sum(:cost)

    @cost_list_conversation = @total_conversations_by_cost.keys.map(&:second).uniq
    @cost_list_notification = @total_notifications_by_cost.keys.map(&:second).uniq
    @costs_list = @cost_list_conversation + @cost_list_notification

    date_list_conversation = @total_conversations_by_cost.keys.map(&:first).uniq
    date_list_notification = @total_notifications_by_cost.keys.map(&:first).uniq
    @date_list = (date_list_conversation + date_list_notification).uniq.sort

    load_messages
  end

  def load_messages
    @user_messages = []

    @date_list.sort { |a, b| b <=> a }.each do |date|
      @date = date
      @data = {
        month: I18n.l(date, format: "%B"),
        year: date.year.to_s,
        type: [],
        cost: [],
        counter: [],
        sub_total: [],
        total: 0
      }

      process_messages
      default_data

      @user_messages << @data
    end
  end

  def default_data
    save_default('conversation') unless @data[:type].include?(t('retailer.profile.payment_plans.index.message_type_conversation'))

    return if @data[:type].include?(t('retailer.profile.payment_plans.index.message_type_notification'))

    save_default('notification')
  end

  def process_messages
    @costs_list.each do |cl|
      if @count_conversations_by_cost.key?([@date, cl]) && @count_conversations_by_cost[[@date, cl]] != 0
        save_data('conversation', cl)
      end

      if @count_notifications_by_cost.key?([@date, cl]) && @count_notifications_by_cost[[@date, cl]] != 0
        save_data('notification', cl)
      end
    end
  end

  def save_data(type, cost)
    if type == 'conversation'
      aux_cost = @total_conversations_by_cost[[@date, cost]] || 0
      count = @count_conversations_by_cost[[@date, cost]] || 0
    else
      aux_cost = @total_notifications_by_cost[[@date, cost]] || 0
      count = @count_notifications_by_cost[[@date, cost]] || 0
    end

    @data[:type] << t("retailer.profile.payment_plans.index.message_type_#{type}")
    @data[:cost] << cost
    @data[:counter] << count
    @data[:sub_total] << aux_cost
    @data[:total] += aux_cost
  end

  def save_default(type)
    @data[:type] << t("retailer.profile.payment_plans.index.message_type_#{type}")
    @data[:cost] << nil
    @data[:counter] << 0
    @data[:sub_total] << 0
  end

  def bot_interactions_counter
    @interactions = []

    total = current_retailer.chat_bot_customers.range_between(@payment_plan.start_date, Time.now)
      .group_by_month(:created_at).count

    total.sort { |a, b| b.first <=> a.first }.map do |key, val|
      @interactions << {
        year: key.year.to_s,
        month: I18n.l(key, format: "%B"),
        total: val
      }
    end
  end
end
