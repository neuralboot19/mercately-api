import React from 'react';
import RecordAudioOutlineIcon from '../icons/RecordAudioOutlineIcon'

const RecordAudioIcon = ({ onMobile, recordAudio }) => (
  <div className="tooltip-top" onClick={() => recordAudio()}>
    <RecordAudioOutlineIcon
      className="fill-icon-input cursor-pointer"
    />
    {/* <i
      className="fas fa-microphone fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => recordAudio()}
    /> */}
    {onMobile === false
      && <div className="tooltiptext">Notas de voz</div>}
  </div>
);

export default RecordAudioIcon;
