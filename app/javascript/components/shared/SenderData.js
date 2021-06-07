import React from 'react';

const SenderData = ({ message }) => (
  <>
    {message.sender_full_name &&
      <>
        <br /><small>Enviado por: {message.sender_full_name}</small>
      </>
    }
  </>
);

export default SenderData;
