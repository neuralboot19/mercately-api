import React from 'react';

const RecordingAudioPanel = ({
  audioMinutes, audioSeconds, cancelAudio, mediaRecorder, onMobile
}) => (
  <div className="d-inline-flex ">
    <div className="tooltip-top cancel-audio-counter">
      <i
        className="far fa-times-circle fs-25 ml-7 mr-7 cursor-pointer"
        onClick={() => cancelAudio()}
      />
      {onMobile === false
        && <div className="tooltiptext">Cancelar</div>}
    </div>
    <div className="time-audio-counter ml-7 mr-7">
      <i className="fas fa-circle fs-15 mr-4" />
      <span className="c-gray-label">
        {audioMinutes}
        :
      </span>
      <span
        className="c-gray-label"
      >
        {audioSeconds}
      </span>
    </div>
    <div className="tooltip-top send-audio-counter">
      <i
        className="far fa-check-circle fs-25 ml-7 mr-7 cursor-pointer"
        onClick={() => mediaRecorder.stop()}
      />
      {onMobile === false
        && <div className="tooltiptext">Enviar</div>}
    </div>
  </div>

);

export default RecordingAudioPanel;
