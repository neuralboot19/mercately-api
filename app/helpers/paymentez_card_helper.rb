module PaymentezCardHelper
  def self.brand(type)
    case type
    when 'vi'
      'Visa'
    when 'mc'
      'Mastercard'
    when 'ax'
      'American Express'
    when 'di'
      'Diners'
    when 'el'
      'Elo'
    when 'cs'
      'Credisensa'
    when 'so'
      'Solidario'
    when 'ex'
      'Exito'
    when 'ak'
      'Alkosto'
    when 'cd'
      'Codensa'
    when 'sx'
      'Sodexo'
    when 'jc'
      'JCB'
    when 'au'
      'Aura'
    when 'cn'
      'Carnet'
    end
  end

  def self.credit_cards(cards)
    cards.map do |cc|
      PaymentezCardHelper.credit_card(cc.id)
    end
  end

  def self.credit_card(card_id)
    card = PaymentezCreditCard.unscoped.find(card_id)
    type = PaymentezCardHelper.brand(card.card_type)
    ["#{type} #{card.number} #{card.expiry_month}/#{card.expiry_year}", card.id]
  end
end
