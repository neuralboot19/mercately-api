import React from 'react';

const SendButton = ({
  onMobile,
  handleSubmit
}) => (
  <div className="tooltip-top">
    <i
      className="fas fa-paper-plane fs-22 mr-5 c-secondary cursor-pointer"
      onClick={(e) => handleSubmit(e)}
    >
    </i>
    {onMobile === false
    && (
      <div className="tooltiptext">Enviar</div>
    )}
  </div>
);

export default SendButton;
