class ChatHistory < ApplicationRecord
  belongs_to :customer
  belongs_to :retailer_user

  # Es el status al que fue marcado automaticamente, o cambiado manualmente el chat
  enum chat_status: %i[chat_open chat_in_process chat_resolved]
  # Es la accion por la cual el chat cambio, puede ser marcado por una
  # accion automatica del usuario, o una accion manual que el usuario realizo
  enum action: %i[mark_as change_to]
end
