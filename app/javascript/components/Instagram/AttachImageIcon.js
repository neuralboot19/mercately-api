import React from 'react';

const AttachImageIcon = ({
  toggleLoadImages,
  onMobile
}) => (
  <div className="tooltip-top">
    <i
      className="fas fa-image fs-22 ml-7 mr-7 cursor-pointer"
      onClick={toggleLoadImages}
    >
    </i>
    {onMobile === false
    && (
      <div className="tooltiptext">Imágenes</div>
    )}
  </div>
);

export default AttachImageIcon;
