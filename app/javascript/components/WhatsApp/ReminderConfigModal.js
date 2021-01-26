import React, { useState } from 'react';
import Modal from 'react-modal';
// eslint-disable-next-line import/no-unresolved
import TemplateImg from 'images/dashboard/ilustracion-cel.png';
import ReminderTemplateItem from './ReminderTemplateItem';
import DatePicker, { registerLocale } from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import es from 'date-fns/locale/es';
registerLocale('es', es)

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

function ReminderConfigModal({
    acceptedFiles,
    cancelTemplate,
    getCleanTemplate,
    isTemplateSelected,
    onMobile,
    screen,
    selectTemplate,
    submitReminder,
    setTemplateType,
    templates,
    templateType,
    isReminderConfigModalOpen,
    toggleReminderConfigModal
}) {
  const [startDate, setStartDate] = useState(new Date());

  return (
    <Modal appElement={document.getElementById("react_content")} isOpen={isReminderConfigModalOpen} style={customStyles}>
      <div className={onMobile ? "row mt-50" : "row"}>
        <div className="col-md-10">
          <p className={onMobile ? "fs-20 mt-0" : "fs-30 mt-0"}>
            {
              'Configurar recordatorio'
            }
          </p>
        </div>
        <div className="col-md-2 t-right">
          <button type="button" onClick={() => toggleReminderConfigModal()}>Cerrar</button>
        </div>
      </div>
      { !isTemplateSelected
        ? (
          <div>
            {
              templates.length > 0
                ? (templates.map((template) => (
                  <ReminderTemplateItem
                    key={template.id}
                    template={template}
                    getCleanTemplate={getCleanTemplate}
                    selectTemplate={selectTemplate}
                    setTemplateType={setTemplateType}
                    onMobile={onMobile}
                  />
                )))
                : (
                  <div className="row">
                    <div className="col-md-6 col-xs-12">
                      <img src={TemplateImg} className="pt-36" />
                    </div>
                    <div className="col-xs-12 col-md-6 t-justify">
                      <h2 className="c-secondary">
                        ¿Qué son las <b>plantillas</b>?
                      </h2>
                      Las plantillas de mensajería de WhatsApp son <b>mensajes preaprobados</b> por WhatsApp para que puedas <b>iniciar una conversación</b> o retomar una conversación con tus clientes.
                      <br/>
                      <br/>
                      <h2 className="c-secondary">Contenido</h2>
                      <ul className="list-checks">
                        <li>
                          Las plantillas se basan en <b>texto</b> y solo deben contener <b>letras</b>
                        </li>
                        <li>
                          <b>No</b> puede contener <b>más de 1024 caracteres</b>
                        </li>
                        <li>
                          No puede incluir lineas extra, pestañas, o más de cuatro espacios consecutivos
                        </li>
                      </ul>
                      <div className="t-center">
                        <br/>
                        <a href={`/retailers/${window.location.pathname.split('/')[2]}/gs_templates`} className="btn btn--cta">
                          <i className="fas fa-plus mr-5"></i>
                          &nbsp;&nbsp;&nbsp;Crear mi primera plantilla&nbsp;&nbsp;
                        </a>
                        <br/>
                        <br/>
                        <a className="btn btn--cta" target="_blank" href="https://mercately.crunch.help/integraciones/como-crear-plantillas-de-whats-app-hsm">
                          <i className="fas fa-book-open mr-5"></i>
                          Instrucciones y limitaciones
                        </a>
                        <br/>
                        <br/>
                      </div>
                    </div>
                  </div>
                )
            }
          </div>
        )
        : (
          <div>
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
                  onChange={date => setStartDate(date)}
                  locale='es'
                  timeCaption='Hora'
                  showTimeSelect
                  timeFormat='p'
                  timeIntervals={1}
                  dateFormat='Pp'
                  id='send_template_at'
                  minDate={new Date()}
                />
              </div>
            </div>
            <div className="row mt-30">
              <div className="col-md-6 t-right">
                <button type="button" onClick={() => cancelTemplate('reminders')}>Cancelar</button>
              </div>
              <div className="col-md-6 t-left">
                <button type="button" onClick={() => submitReminder()}>Guardar</button>
              </div>
            </div>
          </div>
        )}
    </Modal>
  );
};

export default ReminderConfigModal;
