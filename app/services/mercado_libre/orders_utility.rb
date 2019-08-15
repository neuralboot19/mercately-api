module MercadoLibre
  class OrdersUtility
    def prepare_order_feedback(order)
      info = {
        'fulfilled': order.merc_status == 'success',
        'message': order.feedback_message,
        'rating': order.feedback_rating
      }

      if order.merc_status == 'cancelled'
        info['reason'] = order.feedback_reason
        info['restock_item'] = true
      end

      info.to_json
    end
  end
end
