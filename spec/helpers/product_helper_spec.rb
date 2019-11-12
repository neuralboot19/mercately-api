require 'rails_helper'

RSpec.describe ProductHelper, type: :helper do
  let(:product) { create(:product) }

  describe '#ordered_images' do
    context 'when the product does not have images' do
      it 'returns an empty array' do
        @product = product
        expect(helper.ordered_images).to eq([])
      end
    end

    context 'when the product has images and a main one' do
      let(:url) { 'https://miro.medium.com/max/500/1*pgsK9936_OIKWYJpcMicVg.gif' }

      before do
        product.attach_image(url, 'tio_ben.gif', 1)

        tempfile = MiniMagick::Image.open(url)
        tempfile.write('./public/upload-testing.jpg')
        file = ActionDispatch::Http::UploadedFile.new(filename: 'main_image.jpg', content_type:
          'image/jpg', tempfile: tempfile.path)

        product.main_image = file
        product.update_main_picture
        File.delete('./public/upload-testing.jpg')
      end

      it 'returns an array of images' do
        @product = product
        expect(helper.ordered_images.first.id).to eq(product.images.last.id)
      end
    end
  end

  describe '#disabled_meli_statuses' do
    let(:disabled) { %w[payment_required under_review inactive] }

    context 'when meli_status is archived' do
      it 'returns an array with posible statuses' do
        product.update(status: 'archived')
        @product = product
        expect(helper.disabled_meli_statuses).to eq disabled + %w[active paused closed]
      end
    end

    context 'when meli_status is active' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'active')
        @product = product
        expect(helper.disabled_meli_statuses).to eq disabled
      end
    end

    context 'when meli_status is closed' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'closed')
        @product = product
        expect(helper.disabled_meli_statuses).to eq disabled + %w[paused]
      end
    end

    context 'when meli_status is paused' do
      it 'returns an array with posible statuses' do
        product.update(meli_status: 'paused')
        @product = product
        expect(helper.disabled_meli_statuses).to eq disabled + %w[closed]
      end
    end
  end
end
