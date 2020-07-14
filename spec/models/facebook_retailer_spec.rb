require 'rails_helper'

RSpec.describe FacebookRetailer, type: :model do
  describe '#add_sales_channel' do
    let(:retailer) { create(:retailer) }

    context 'when a facebook retailer is created' do
      it 'creates a messenger sales channel' do
        expect(retailer.sales_channels.size).to eq(0)

        FacebookRetailer.create(retailer: retailer)

        retailer.reload
        expect(retailer.sales_channels.size).to eq(1)
        expect(retailer.sales_channels.first.channel_type).to eq('messenger')
      end
    end
  end
end
