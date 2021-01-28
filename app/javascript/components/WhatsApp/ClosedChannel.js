import React from 'react';

const ClosedChannel = ({ openModal, openReminderConfigModal, allowReminders }) => (
  <div className="col-xs-12">
    <p>
      {'Este canal de chat se encuentra cerrado. Si lo desea puede enviar una '}
      <a href="#" onClick={() => openModal()}>plantilla</a>
      {allowReminders &&
        <span> o <a href="#" onClick={() => openReminderConfigModal()}>enviar un recordatorio</a></span>
      }
      .
    </p>
  </div>
);

export default ClosedChannel;
