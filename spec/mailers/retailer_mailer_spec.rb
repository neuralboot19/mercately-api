require 'rails_helper'

RSpec.describe RetailerMailer, type: :mailer do
  describe '.welcome' do
    subject(:mail) { described_class.welcome(retailer_user).deliver_now }

    let(:retailer_user) { create(:retailer_user, :with_retailer, email: 'retailer@example.com') }

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

  describe '.invitation' do
    subject(:mail) { described_class.invitation(retailer_user).deliver_now }

    let(:retailer_user) do
      create(
        :retailer_user,
        retailer: retailer,
        email: 'retailer@example.com',
        first_name:'Test',
        last_name: 'Test'
      )
    end

    let(:retailer) { create(:retailer, name: 'Retailer Example') }

    it 'shows full_name to invited' do
      expect(mail.body.encoded).to include("Hola #{retailer_user.full_name}")
    end

    it 'shows the correct subject to invited' do
      expect(mail.subject).to eq('Retailer Example te ha invitado a su equipo en Mercately')
    end

    it 'shows the correct receiver email to invited' do
      expect(mail.to).to eq([retailer_user.email])
    end

    it 'shows the correct sender email to invited' do
      expect(mail.from).to eq(['hola@mercately.com'])
    end
  end

  describe '.chat_assignment_notification' do
    subject(:mail) { described_class.chat_assignment_notification(agent_customer, retailer_user).deliver_now }

    let(:retailer_user) do
      create(:retailer_user, :with_retailer, retailer: retailer, email: 'retailer@example.com', first_name:
        'Test', last_name: 'Test')
    end

    let(:retailer) { create(:retailer, name: 'Retailer Example') }
    let(:customer) { create(:customer) }
    let(:agent_customer) { create(:agent_customer, retailer_user: retailer_user, customer: customer) }

    it 'shows full_name to assigned retailer user' do
      expect(mail.body.encoded).to include("Hola #{retailer_user.full_name}")
    end

    it 'shows the correct subject to assigned retailer user' do
      expect(mail.subject).to eq('Nuevo chat asignado')
    end

    it 'shows the correct receiver email to assigned retailer user' do
      expect(mail.to).to eq([retailer_user.email])
    end

    it 'shows the correct sender email to assigned retailer user' do
      expect(mail.from).to eq(['hola@mercately.com'])
    end
  end
end
