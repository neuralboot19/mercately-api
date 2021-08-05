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

  describe '.imported_customers' do
    subject(:mail) { described_class.imported_customers(retailer_user, []).deliver_now }

    let(:retailer_user) { create(:retailer_user, :with_retailer, email: 'retailer@example.com') }

    it 'shows the correct subject' do
      expect(mail.subject).to eq('Importación de Clientes Completa')
    end

    it 'shows the correct receiver email' do
      expect(mail.to).to eq([retailer_user.email])
    end

    it 'shows the correct sender email' do
      expect(mail.from).to eq(['hola@mercately.com'])
    end

    context 'when there are not errors in the importing file' do
      errors = []
      subject(:mail) { described_class.imported_customers(retailer_user, errors).deliver_now }

      it 'shows a success message' do
        expect(mail.body.encoded).to include('La importaci')
        expect(mail.body.encoded).to include('de clientes culmin')
        expect(mail.body.encoded).to include('exitosamente')
      end
    end

    context 'when there are errors in the importing file' do
      subject(:mail) { described_class.imported_customers(retailer_user, errors).deliver_now }

      let(:errors) { { errors: ['Fila 2 inválida: Error en el formato del email'] } }

      it 'shows the errors messages' do
        expect(mail.body.encoded).to include('Error en el formato del email')
      end
    end
  end
end
