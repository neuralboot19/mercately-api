module AutomaticAnswers
  class AutomaticAnswerDayQuery
    # Se verifica si existe al menos un mensaje en el mismo dia
    # que se mando a guardar como all day
    def invalid_all_day?(answer_ids, day)
      AutomaticAnswerDay.where('automatic_answer_id IN (?) AND day = ?', answer_ids, day).exists?
    end

    # Se verifica que no se crucen ninguno de los horarios seleccionados
    # para el mensaje que se intenta guardar
    def invalid_schedule?(answer_ids, answer_info)
      AutomaticAnswerDay.where('automatic_answer_id IN (?) AND day = ? AND (all_day = TRUE OR ' \
        '(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?) OR (start_time >= ? ' \
        'AND end_time < ?))', answer_ids, answer_info['day'], answer_info['start_time'],
        answer_info['start_time'], answer_info['end_time'], answer_info['end_time'],
        answer_info['start_time'], answer_info['end_time']).exists?
    end
  end
end
