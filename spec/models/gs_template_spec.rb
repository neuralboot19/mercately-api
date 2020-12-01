require 'rails_helper'

RSpec.describe GsTemplate, type: :model do
  subject { build(:gs_template, retailer: retailer) }
  let(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }
  let(:retailer) { retailer_user.retailer }

  describe '#example_match?' do
    it 'checks either text and example match' do
      expect(subject.send(:example_match?)).to be true
      expect(subject.save).to be true
    end

    context 'when example or text didnt match' do
      it 'does not save' do
        subject.text = 'My Text with var {{1}} 2'
        expect(subject.send(:example_match?)).to eq ['El texto y el ejemplo no coinciden']
        expect(subject.save).to be false
      end
    end
  end

  describe '#format_label' do
    it 'formats the label field before saving' do
      subject.label = 'Example label'
      expect(subject.save).to be true
      expect(subject.label).to eq 'example_label'
    end
  end

  describe '#vars_repeated?' do
    it 'checks if text field contains vars repeated' do
      subject.text = 'My Text with var {{1}}, {{1}}'
      expect(subject.save).to be false
    end
  end
end
