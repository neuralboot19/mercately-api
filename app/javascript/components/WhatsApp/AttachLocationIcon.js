import React from 'react';

const AttachLocationIcon = ({ getLocation, onMobile }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-map-marker-alt fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => getLocation()}
    />
    {onMobile === false
    && <div className="tooltiptext">Ubicación</div>}
  </div>
);

export default AttachLocationIcon;
