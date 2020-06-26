class CreateSalesChannel < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_channels do |t|
      t.references :retailer
      t.string :title
      t.string :web_id
      t.integer :channel_type, default: 0

      t.timestamps
    end

    Retailer.all.each do |retailer|
      if retailer.meli_retailer.present?
        retailer.sales_channels.create(title: 'Mercado Libre', channel_type: 1)
      end

      if retailer.whatsapp_integrated?
        retailer.sales_channels.create(title: 'WhatsApp', channel_type: 2)
      end

      if retailer.facebook_retailer.present?
        retailer.sales_channels.create(title: 'Messenger', channel_type: 3)
      end
    end
  end
end
