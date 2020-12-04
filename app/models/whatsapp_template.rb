class WhatsappTemplate < ApplicationRecord
  belongs_to :retailer

  enum status: %i[inactive active]
  enum template_type: %i[text image file]

  def clean_template
    text.gsub('\\*', '*')
  end

  # Se busca los asteriscos en el texto para identificar los campos editables que hay
  # Se compara luego con la cantidad de parametros enviados, asi sabemos si se envio
  # la misma cantidad.
  # Cuando a un asterisco lo precede un \ significa que no es un campo editable, sino
  # que es para dar formato de negrita en el mensaje.
  def check_params_match(params)
    params_required = 0
    params_sent = params[:template_params].present? ? params[:template_params].size : 0
    splitted_text = text.chars

    splitted_text.each_with_index do |ch, index|
      params_required = params_required + 1 if ch == '*' && (index == 0 || splitted_text[index - 1] != '\\')
    end

    [params_required == params_sent, params_required, params_sent]
  end

  # Se busca los asteriscos en el texto para identificar los campos editables que hay
  # Se inserta en cada campo editable los parameros enviados en orden, y se devuelve
  # el texto final.
  # Cuando a un asterisco lo precede un \ significa que no es un campo editable, sino
  # que es para dar formato de negrita en el mensaje.
  def template_text(params)
    splitted_text = text.chars
    template_params_index = 0

    splitted_text.each_with_index do |ch, index|
      if ch == '*' && (index == 0 || splitted_text[index - 1] != '\\')
        splitted_text[index] = params[:template_params][template_params_index]
        template_params_index = template_params_index + 1
      end
    end

    splitted_text.join
  end
end
