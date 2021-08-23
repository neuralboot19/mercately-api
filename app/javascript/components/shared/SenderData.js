import React from 'react';

const SenderData = ({ senderFullName, isNote }) => (
  <p className="m-0 text-right">
    <small>{isNote ? 'Creado' : 'Enviado'} por: {senderFullName}</small>
  </p>
);

export default SenderData;
