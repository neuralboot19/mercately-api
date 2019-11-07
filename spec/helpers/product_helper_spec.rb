require 'rails_helper'

RSpec.describe ProductHelper, type: :helper do
  describe '#ordered_images' do
    let(:product) { create(:product) }

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
end
