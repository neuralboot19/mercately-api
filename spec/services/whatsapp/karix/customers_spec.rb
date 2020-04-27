require 'rails_helper'

RSpec.describe Whatsapp::Karix::Customers do
  subject(:customer_service) { described_class.new }

  let(:retailer) { create(:retailer) }

  let(:karix_response) do
    {
      'account_uid': '3a9f05a1-4e59-4504-9ca9-be9ec1934f2b',
      'channel': 'whatsapp',
      'channel_details': {
        'whatsapp': {
          'platform_fee': '0.004',
          'type': 'conversation',
          'whatsapp_fee': '0'
        }
      },
      'content': {
        'text': 'New Whatsapp message'
      },
      'content_type': 'text',
      'country': 'EC',
      'created_time': '2020-03-18T15:01:14.624018Z',
      'delivered_time': nil,
      'destination': '+593998377063',
      'direction': 'outbound',
      'error': nil,
      'redact': false,
      'refund': nil,
      'sent_time': nil,
      'source': '+13253077759',
      'status': 'queued',
      'total_cost': '0.004',
      'uid': '87f3c742-95e3-4bb3-a671-cce2705e1a21',
      'updated_time': nil
    }.with_indifferent_access
  end

  describe '.save_customer' do
    it 'saves a customer' do
      expect { customer_service.save_customer(retailer, karix_response) }.to change { Customer.count }.by(1)
    end

    it 'saves the country correctly' do
      customer = customer_service.save_customer(retailer, karix_response)
      expect(customer.country_id).to eq('EC')
    end
  end
end
