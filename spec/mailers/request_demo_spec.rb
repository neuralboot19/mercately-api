require 'rails_helper'

RSpec.describe RequestDemoMailer, type: :mailer do
  describe '#demo_requested' do
    subject(:mail) { described_class.demo_requested(client_data) }

    let(:client_data) do
      {
        name: 'John Doe',
        email: 'john@doe.com',
        company: 'Acme Inc',
        phone: '098-333-4444',
        message: 'Hi, I\'d like a demo'
      }
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Mercately demo requested by #{client_data[:name]}")
      expect(mail.to).to eq([
                              'hola@mercately.com',
                              'henry2992@hotmail.com',
                              'pvelasquez9294@gmail.com',
                              'jalagut8@gmail.com'
                            ])
      expect(mail.from).to eq(['hola@mercately.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(client_data[:name])
      expect(mail.body.encoded).to match(client_data[:email])
      expect(mail.body.encoded).to match(client_data[:company])
      expect(mail.body.encoded).to match(client_data[:phone])
      expect(mail.body.encoded).to match(client_data[:message])
    end
  end
end
