import React from 'react';
import AttachImageOutlineIcon from '../icons/AttachImageOutlineIcon'

const AttachImageIcon = ({ onMobile, toggleLoadImages }) => (
  <div onClick={() => toggleLoadImages()} className="tooltip-top">
    <AttachImageOutlineIcon
      className="fill-icon-input cursor-pointer"
    />
    {onMobile === false
    && <div className="tooltiptext">Imágenes</div>}
  </div>
);

export default AttachImageIcon;
