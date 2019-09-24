module MercadoLibre
  class OrdersUtility
    def prepare_order_feedback(order)
      info = {
        'fulfilled': order.status == 'success',
        'message': order.feedback_message,
        'rating': order.feedback_rating
      }

      if order.status == 'cancelled'
        info['reason'] = order.feedback_reason
        info['restock_item'] = true
      end

      info.to_json
    end
  end
end
