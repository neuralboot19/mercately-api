module StripeCardHelper
  def stripe_cards(cards)
    cards.map do |cc|
      stripe_credit_card_selection(cc)
    end
  end

  def stripe_credit_card(card_id)
    card = PaymentMethod.unscoped.find_by(id: card_id)
    return [t('retailer.profile.payment_plans.index.card_not_found')] if card.nil?
    pm = JSON.parse(card.payment_payload)

    [
      "****#{pm['card']['last4']} #{pm['card']['exp_month']}/#{pm['card']['exp_year']}",
      card.stripe_pm_id,
      pm['card']['brand']&.to_s
    ]
  end

  def stripe_credit_card_selection(card)
    pm = JSON.parse(card.payment_payload)

    [
      "#{pm['card']['brand']} ****#{pm['card']['last4']} #{pm['card']['exp_month']}/#{pm['card']['exp_year']}",
      card.stripe_pm_id
    ]
  end
end
