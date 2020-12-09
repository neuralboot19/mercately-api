import React from 'react';

const RecordAudioIcon = ({ onMobile, recordAudio }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-microphone fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => recordAudio()}
    />
    {onMobile === false
      && <div className="tooltiptext">Notas de voz</div>}
  </div>
);

export default RecordAudioIcon;
