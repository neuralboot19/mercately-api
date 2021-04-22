require 'rails_helper'

RSpec.describe RequestDemoMailer, type: :mailer do
  describe '#demo_requested' do
    subject(:mail) { described_class.demo_requested(demo_request_lead) }

    let(:demo_request_lead) do
      create(:demo_request_lead,
        name: 'John Doe',
        email: 'john@doe.com',
        company: 'Acme Inc',
        phone: '098-333-4444',
        message: 'Hi, I would like a demo'
      )
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Mercately demo requested by #{demo_request_lead.name}")
      expect(mail.to).to eq([
                              'hola@mercately.com',
                              'henry2992@hotmail.com',
                              'pvelasquez9294@gmail.com',
                              'jalagut8@gmail.com'
                            ])
      expect(mail.from).to eq(['hola@mercately.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(demo_request_lead.name)
      expect(mail.body.encoded).to match(demo_request_lead.email)
      expect(mail.body.encoded).to match(demo_request_lead.company)
      expect(mail.body.encoded).to match(demo_request_lead.phone.gsub('+', ''))
      expect(mail.body.encoded).to match(demo_request_lead.message)
    end
  end
end
