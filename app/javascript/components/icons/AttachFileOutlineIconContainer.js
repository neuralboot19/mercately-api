import React from 'react';
import AttachFileOutlineIcon from '../icons/AttachFileOutlineIcon'

const AttachFileIcon = ({ onMobile }) => (
  <div onClick={() => document.querySelector('#attach-file').click()} className="tooltip-top">
    <AttachFileOutlineIcon
      className="fill-icon-input cursor-pointer"
    />
    {onMobile === false
    && <div className="tooltiptext">Archivos</div>}
  </div>
);

export default AttachFileIcon;
