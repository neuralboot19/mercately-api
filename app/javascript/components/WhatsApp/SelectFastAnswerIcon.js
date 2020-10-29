import React from 'react';

const SelectFastAnswerIcon = ({ onMobile, toggleFastAnswers }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-bolt fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => toggleFastAnswers()}
    />
    {onMobile === false
      && <div className="tooltiptext">Respuestas Rápidas</div>}
  </div>
);

export default SelectFastAnswerIcon;
