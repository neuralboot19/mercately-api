module AddSalesChannelConcern
  extend ActiveSupport::Concern

  def add_sales_channel
    case self.class.name
    when 'MeliRetailer'
      add_ml_channel
    when 'FacebookRetailer'
      add_msn_channel
    when 'Retailer'
      add_ws_channel
    end
  end

  private

    def add_ml_channel
      return if retailer.sales_channels.exists?(channel_type: 'mercadolibre')

      retailer.sales_channels.create(title: 'Mercado Libre', channel_type: 'mercadolibre')
    end

    def add_msn_channel
      return if retailer.sales_channels.exists?(channel_type: 'messenger')

      retailer.sales_channels.create(title: 'Messenger', channel_type: 'messenger')
    end

    def add_ws_channel
      return if whatsapp_integrated? == false || sales_channels.exists?(channel_type: 'whatsapp')

      sales_channels.create(title: 'WhatsApp', channel_type: 'whatsapp')
    end
end
