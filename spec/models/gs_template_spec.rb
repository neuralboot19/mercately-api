require 'rails_helper'

RSpec.describe GsTemplate, type: :model do
  subject { build(:gs_template, retailer: retailer) }
  let(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }
  let(:retailer) { retailer_user.retailer }

  describe '#format_label' do
    it 'formats the label field before saving' do
      subject.label = 'Example label'
      expect(subject.save).to be true
      expect(subject.label).to eq 'example_label'
    end
  end

  describe '#vars_repeated?' do
    context 'when there are repeated vars' do
      it 'does not save the template' do
        subject.text = 'My Text with var {{1}}, {{1}}'
        expect(subject.save).to be false
      end
    end

    context 'when there are not repeated vars' do
      it 'saves the template' do
        subject.text = 'My Text with var {{1}}, {{2}}'
        expect(subject.save).to be true
      end
    end
  end
end
