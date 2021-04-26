module WhatsappTemplateHelper
  def whatsapp_template_type(type)
    return 'Texto' if type == 'text'
    return 'Imagen' if type == 'image'

    'PDF'
  end

  # Convierte los * (excepto los \*) en inputs de texto con el selector de columnas de customers
  def template_text(text)
    selector = customer_columns_list.map do |cl|
      "
      <div class=\"c-secondary panel-options-items\" style=\"width: 300px !important;\" onmousedown=\"insertDynamicFieldInput('#{cl[1]}', this)\">
        #{cl[0]}
        <small class=\"c-grey\">{{#{cl[1]}}}</small>
      </div>
      "
    end
    selector = selector.join
    txt = text.gsub(/[^\\]\*/) do |match|
      match.gsub(/\*/,
                 "
      <div class=\"d-inline-block\">
        <input class=\"deactivate-on-selection input-header input-border\" required onfocus=\"showListOptions(this)\" onblur=\"hideListOptions(this)\" type=\"text\" name=\"campaign[content_params][]\">
        <div id=\"list-options-input\" style=\"width: 300px !important;\" class=\"input-webhook-options absolute-panel-options d-none\">
          <div class=\"panel-options-title\">Ingresa un valor o selecciona un campo</div>
          #{selector}
        </div>
      </div>
      ")
    end
    txt.gsub!(/\\\*/, '*')
    txt.html_safe
  end
end
