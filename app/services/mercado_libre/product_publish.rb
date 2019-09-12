module MercadoLibre
  class ProductPublish
    def initialize(retailer)
      @retailer = retailer
      @meli_retailer = @retailer.meli_retailer
      @api = MercadoLibre::Api.new(@meli_retailer)
      @utility = MercadoLibre::ProductsUtility.new
    end

    def re_publish_product(product)
      url = @api.get_re_publish_product_url(product.meli_product_id)
      conn = Connection.prepare_connection(url)
      response = Connection.post_request(conn, @utility.prepare_re_publish_product(product))
      puts response.body if response.status != 201
    end

    def send_update(product, past_meli_status = nil)
      url = @api.get_product_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      response = Connection.put_request(conn, @utility.prepare_product_update(product, past_meli_status))
      push_description_update(product)
      if response.status == 200
        load_pictures_to_ml(product)
      else
        puts response.body
      end
    end

    def push_description_update(product)
      url = @api.get_product_description_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      Connection.put_request(conn, @utility.prepare_product_description_update(product))
    end

    def load_pictures_to_ml(product, only_main_picture = false)
      return if product.images.blank?

      @url = @api.prepare_load_pictures_url
      @url_pic_product = @api.prepare_link_pictures_to_product_url(product)
      product.images.each do |img|
        next unless img.filename.to_s.include?('.')
        next if img.id != product.main_picture_id && only_main_picture

        load_image(product, img)
      end
    end

    def load_image(product, img)
      file = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{img.key}"

      tempfile = { source: file.to_s }.to_json
      conn = Connection.prepare_connection(@url)
      response = Connection.post_request(conn, tempfile)

      if product.meli_product_id.blank?
        body = JSON.parse(response.body)
        ActiveStorage::Blob.find_by(key: img.key).update(filename: body['id'])
        return
      end

      if response.status == 201
        body = JSON.parse(response.body)

        params = { id: body['id'] }.to_json
        conn = Connection.prepare_connection(@url_pic_product)
        response = Connection.post_request(conn, params)

        ActiveStorage::Blob.find_by(key: img.key).update(filename: body['id']) if response.status == 200
      else
        puts response.body
      end
    end

    def automatic_re_publish(product)
      return unless product.meli_status == 'closed' &&
                    product.meli_stop_time == product.meli_end_time &&
                    product.status == 'active'

      re_publish_product(product)
    end

    def send_status_update(product)
      url = @api.get_product_url product.meli_product_id
      conn = Connection.prepare_connection(url)
      response = Connection.put_request(conn, @utility.prepare_product_status_update(product))

      puts response.body if response.status != 200
    end
  end
end
