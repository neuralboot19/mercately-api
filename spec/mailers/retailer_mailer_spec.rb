require 'rails_helper'

RSpec.describe RetailerMailer, type: :mailer do
  describe '.welcome' do
    subject(:retailer_user) { create(:retailer_user, email: 'retailer@example.com') }
    subject(:mail) { described_class.welcome(retailer_user).deliver_now }

    it 'shows the correct subject to retailer' do
      expect(mail.subject).to eq('Bienvenido a Mercately')
    end

    it 'shows the correct receiver email to retailer' do
      expect(mail.to).to eq([retailer_user.email])
    end

    it 'shows the correct sender email to retailer' do
      expect(mail.from).to eq(['hola@mercately.com'])
    end
  end
end
