import React from 'react';

const BlockedUserMessage = ({ toggleNoteModal }) => {
  return (
    <div className="col-xs-12 p-24">
      <p>
        Este número ha sido bloqueado, por lo tanto no puedes recibir sus mensajes. Si lo deseas puedes desbloquearlo
        en cualquier momento o <a href="#" onClick={() => toggleNoteModal()}>añadir una nota</a>.
      </p>
    </div>
  );
};

export default BlockedUserMessage;
