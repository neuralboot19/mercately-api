import React, { useState } from 'react';
import DatePicker from "react-datepicker";

const SelectedReminderTemplate = ({
  setTemplateType,
  templateType,
  acceptedFiles,
  onMobile,
  cancelTemplate,
  submitReminder,
  screen
}) => {
  const [startDate, setStartDate] = useState(new Date());

  return (
    <div className="input-from-backend mb-24">
      <div className="row">
        <div className="col-md-12">
          {`[${setTemplateType(templateType)}] `}
          {screen}
        </div>
      </div>
      {templateType !== 'text'
          && (
            <div id="template-file" className="col-md-12">
              <br />
              <input type="file" name="file" id="template_file" accept={acceptedFiles} />
            </div>
          )}
      <div className="row mt-30">
        <div className="col-md-12">
          <label className="mr-10">Horario de envío:</label>
          <DatePicker
            selected={startDate}
            onChange={(date) => setStartDate(date)}
            locale="es"
            timeCaption="Hora"
            showTimeSelect
            timeFormat="p"
            timeIntervals={1}
            dateFormat="Pp"
            id="send_template_at"
            minDate={new Date()}
          />
        </div>
      </div>
      <div className="d-flex justify-content-center justify-content-md-end mt-30">
        <div className={onMobile ? "mr-5" : "mr-15"}>
          <a className="border-8 bg-light text-gray-dark p-12 border-gray" onClick={() => cancelTemplate('reminders')}>Cancelar</a>
        </div>
        <div className="">
          <a className="border-8 bg-blue text-white p-12" onClick={() => submitReminder()}>Guardar</a>
        </div>
      </div>
    </div>
  );
};

export default SelectedReminderTemplate;
