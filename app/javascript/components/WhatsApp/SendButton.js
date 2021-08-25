import React from 'react';
import SendOutlineIcon from '../icons/SendOutlineIcon';

const SendButton = ({ handleSubmit, onMobile }) => (
  <div className="tooltip-top" onClick={(e) => handleSubmit(e)}>
    <span className="h-32 w-32 border-4 bg-blue p-8 flex-center-xy">
      <SendOutlineIcon
        className="fill-white cursor-pointer"
      />
    </span>
    {onMobile === false
      && <div className="tooltiptext">Enviar</div>}
  </div>
);

export default SendButton;
