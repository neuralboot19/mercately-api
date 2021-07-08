import React from 'react';
import moment from 'moment';
import ShowMoreText from 'react-show-more-text';

const AutomationsTabContent = ({
  reminders,
  cancelReminder,
  showAutomationSettings
}) => {
  const reminderStatus = (reminder) => {
    switch (reminder.status) {
      case 'scheduled':
        return (
          <>
            <a className="cookie cookie--yellow fs-12 dropdown__button fw-bold no-style" href="#!">
              Pendiente
              <i className="fas fa-caret-down c-black ml-4" />
            </a>
            <ul className="dropdown__menu dropdown__menu--react">
              <li className="t-left">
                <a href="#!" className="c-black no-style" onClick={() => cancelReminder(reminder.web_id)}>
                  <i className="fas fa-angle-right mr-8" />
                  Cancelar
                </a>
              </li>
            </ul>
          </>
        );
      case 'sent':
        return <b className="cookie cookie--green fs-12" value="0">Envíado</b>;
      case 'cancelled':
        return <b className="cookie cookie--red fs-12" value="3">Cancelado</b>;
      default:
        return <b className="cookie cookie--red fs-12" value="3">Fallido</b>;
    }
  };

  return (
    <div className="custome_fields" style={{ display: showAutomationSettings }}>
      <div className="details_holder">
        <span>Recordatorios</span>
      </div>
      { (reminders.length > 0) ? (
        reminders.map((reminder) => (
          <div className="bordered-container py-8 px-2 mb-8">
            <div className="row mb-8">
              <div className="col-xs-6 fz-12 truncate-js">
                <ShowMoreText
                  more="Ver más"
                  less="Ver menos"
                  expanded={false}
                >
                  {reminder.template_text}
                </ShowMoreText>
                <span className="c-grey">
                  {reminder.send_at}
                </span>
              </div>
              <div className="col-xs-6 t-center p-0">
                {reminderStatus(reminder)}
              </div>
            </div>
          </div>
        ))
      ) : (
        <div className="bordered-container py-8 px-2">
          <div className="t-center">Sin recordatorios programados</div>
        </div>
      )}
    </div>
  );
};

export default AutomationsTabContent;
