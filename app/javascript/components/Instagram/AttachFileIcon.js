import React from 'react';

const AttachFileIcon = ({ onMobile }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-paperclip fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => document.querySelector('#attach-file').click()}
    >
    </i>
    {onMobile === false
    && (
    <div className="tooltiptext">Archivos</div>
    )}
  </div>
);

export default AttachFileIcon;
