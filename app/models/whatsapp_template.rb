class WhatsappTemplate < ApplicationRecord
  belongs_to :retailer

  enum status: %i[inactive active]
  enum template_type: %i[text image document video location]

  def clean_template
    text.gsub('\\*', '*')
  end

  # Se busca los asteriscos en el texto para identificar los campos editables que hay
  # Se compara luego con la cantidad de parametros enviados, asi sabemos si se envio
  # la misma cantidad.
  # Cuando a un asterisco lo precede un \ significa que no es un campo editable, sino
  # que es para dar formato de negrita en el mensaje.
  def check_params_match(params)
    params_required = text.gsub(/[^\\]\*/).count
    params_sent = params[:template_params].present? ? params[:template_params].size : 0

    [params_required == params_sent, params_required, params_sent]
  end

  # Se busca los asteriscos en el texto para identificar los campos editables que hay
  # Se inserta en cada campo editable los parameros enviados en orden, y se devuelve
  # el texto final.
  # Cuando a un asterisco lo precede un \ significa que no es un campo editable, sino
  # que es para dar formato de negrita en el mensaje.
  def template_text(params)
    text.gsub(/[^\\]\*/).with_index do |match, index|
      match.gsub(/\*/, params[:template_params][index].to_s)
    end
  end
end
