import React from 'react';

const AttachProductIcon = ({
  toggleProducts,
  onMobile
}) => (
  <div className="tooltip-top">
    <i
      className="fas fa-shopping-bag fs-22 ml-7 mr-7 cursor-pointer"
      onClick={toggleProducts}
    >
    </i>
    {onMobile === false
    && (
      <div className="tooltiptext">Productos</div>
    )}
  </div>
);

export default AttachProductIcon;
