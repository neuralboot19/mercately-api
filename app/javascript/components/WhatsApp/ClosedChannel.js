import React from 'react';

const ClosedChannel = ({ openModal, openReminderConfigModal, toggleNoteModal, toggleDealModal }) => (
  <div className="col-xs-12 p-24">
    <p>
      {'Este canal de chat se encuentra cerrado. Si lo desea puede enviar una '}
      <a href="#" onClick={() => openModal()}>plantilla</a>
      <span>
        ,&nbsp;
        <a href="#" onClick={() => openReminderConfigModal()}>enviar un recordatorio</a>
        {ENV.INTEGRATION === '1' && (
          <>
            ,&nbsp;
            <a href="#" onClick={() => toggleNoteModal()}>añadir una nota en el chat</a>
          </>
        )}
        &nbsp;o&nbsp;
        <a href="#" onClick={() => toggleDealModal()}>crear una negociación</a>
      </span>
      .
    </p>
  </div>
);

export default ClosedChannel;