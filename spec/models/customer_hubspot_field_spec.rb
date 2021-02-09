require 'rails_helper'

RSpec.describe CustomerHubspotField, type: :model do
  subject { build(:customer_hubspot_field) }

  describe '#same_field_type' do
    it 'validates both input types match' do
      expect(subject.save).to be true
    end

    context 'when different type' do
      it 'does not save' do
        subject.hubspot_field.hubspot_type = 'number'
        expect(subject.save).to be false
      end
    end
  end
end
