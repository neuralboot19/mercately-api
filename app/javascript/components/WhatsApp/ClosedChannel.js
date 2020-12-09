import React from 'react';

const ClosedChannel = ({ openModal }) => (
  <div className="col-xs-12">
    <p>
      {'Este canal de chat se encuentra cerrado. Si lo desea puede enviar una '}
      <a href="#" onClick={() => openModal()}>plantilla</a>
      .
    </p>
  </div>
);

export default ClosedChannel;
