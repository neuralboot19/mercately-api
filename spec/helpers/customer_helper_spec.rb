require 'rails_helper'

RSpec.describe CustomerHelper, type: :helper do
  describe '#customer_ordering_options' do
    it 'returns a list of options to filter' do
      expect(helper.customer_ordering_options.size).to eq(13)
    end
  end
end
