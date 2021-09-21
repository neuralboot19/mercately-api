import React from 'react';

const ClosedChannel = ({ openModal, openReminderConfigModal, toggleNoteModal }) => (
  <div className="col-xs-12 p-24">
    <p>
      {'Este canal de chat se encuentra cerrado. Si lo desea puede enviar una '}
      <a href="#" onClick={() => openModal()}>plantilla</a>
      <span>
        {ENV.INTEGRATION === '1' ? (
          <>
            ,&nbsp;
          </>
        ) : (
          <>
            &nbsp;o&nbsp;
          </>
        )}
        <a href="#" onClick={() => openReminderConfigModal()}>enviar un recordatorio</a>
        {ENV.INTEGRATION === '1' && (
          <>
            &nbsp;o&nbsp;
            <a href="#" onClick={() => toggleNoteModal()}>añadir una nota en el chat</a>
          </>
        )}
      </span>
      .
    </p>
  </div>
);

export default ClosedChannel;
