import React from 'react';

const ReminderIcon = ({ onMobile, openReminderConfigModal }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-stopwatch fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => openReminderConfigModal()}
    />
    {onMobile === false
      && <div className="tooltiptext">Recordatorios</div>}
  </div>
);

export default ReminderIcon;
