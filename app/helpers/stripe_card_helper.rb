module StripeCardHelper
  def stripe_cards(cards)
    cards.map do |cc|
      stripe_credit_card(cc.id)
    end
  end

  def stripe_credit_card(card_id)
    card = PaymentMethod.unscoped.find_by(id: card_id)
    return ['Tarjeta no encontrada'] if card.nil?
    pm = JSON.parse(card.payment_payload)
    [
      "#{pm['card']['brand']} #{pm['card']['last4']} #{pm['card']['exp_month']}/#{pm['card']['exp_year']}",
      card.stripe_pm_id
    ]
  end
end
