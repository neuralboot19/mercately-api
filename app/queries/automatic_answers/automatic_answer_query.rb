module AutomaticAnswers
  class AutomaticAnswerQuery
    # Se busca el mensaje que este siempre activo para la plataforma y el usuario deseado
    def always_active_answer(retailer_id, platform, message_type)
      AutomaticAnswer.where("retailer_id = ? AND #{platform} = TRUE AND (message_type = ? OR message_type = 2) " \
        'AND always_active = TRUE', retailer_id, message_type).first
    end

    # Se busca el mensaje que este en el horario para la plataforma y el usuario deseado
    def match_schedule_answer(retailer_id, platform, message_type, time)
      AutomaticAnswer.joins('LEFT JOIN automatic_answer_days aad ON aad.automatic_answer_id = automatic_answers.id')
        .where("retailer_id = ? AND #{platform} = TRUE AND (message_type = ? OR message_type = 2) AND aad.day = ? " \
        "AND aad.start_time <= ? AND aad.end_time > ?", retailer_id, message_type, time.wday, time.hour, time.hour)
        .first
    end
  end
end
