import React from 'react';
// eslint-disable-next-line import/no-unresolved
import ReminderIcon from 'images/new_design/reminder-chat.svg';

const RemindersButton = ({ openReminderConfigModal }) => (
  <div className="d-inline-block">
    <div onClick={openReminderConfigModal} className="rounded-pill border border-gray ml-12 cursor-pointer fs-12 p-10 mb-16">
      <img className="mr-4" src={ReminderIcon} alt="reminders icon" />
      <span>Crear recordatorio</span>
    </div>
  </div>
);

export default RemindersButton;
