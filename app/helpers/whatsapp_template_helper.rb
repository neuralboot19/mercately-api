module WhatsappTemplateHelper
  def whatsapp_template_type(type)
    return 'Texto' if type == 'text'
    return 'Imagen' if type == 'image'

    'PDF'
  end
end
