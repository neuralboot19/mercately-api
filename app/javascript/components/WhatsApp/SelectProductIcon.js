import React from 'react';

const SelectProductIcon = ({ onMobile, toggleProducts }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-shopping-bag fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => toggleProducts()}
    />
    {onMobile === false
      && <div className="tooltiptext">Productos</div>}
  </div>
);

export default SelectProductIcon;
