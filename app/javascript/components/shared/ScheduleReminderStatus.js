import React from 'react';

const ScheduleReminderStatus = ({reminder, cancelReminder}) => {
  return (
    <span className="p-relative">
      <a className="cookie cookie--yellow fs-12 dropdown__button fw-bold no-style c-black" href="#!">
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
    </span>
  )
};

export default ScheduleReminderStatus;
