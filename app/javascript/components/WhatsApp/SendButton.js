import React from 'react';

const SendButton = ({ handleSubmit, onMobile }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-paper-plane fs-22 mr-5 c-secondary cursor-pointer"
      onClick={(e) => handleSubmit(e)}
    />
    {onMobile === false
      && <div className="tooltiptext">Enviar</div>}
  </div>
);

export default SendButton;
