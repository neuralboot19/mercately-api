module MercadoLibre
  class OrdersUtility
    def prepare_order_feedback(order)
      {
        'fulfilled': false,
        'rating': order.feedback_rating,
        'message': order.feedback_message,
        'reason': order.feedback_reason,
        'restock_item': true
      }.to_json
    end
  end
end
