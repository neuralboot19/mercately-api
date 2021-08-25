import React from 'react';

const RecordingAudioPanel = ({
  audioMinutes, audioSeconds, cancelAudio, mediaRecorder, onMobile
}) => (
  <div className="d-inline-flex ">
    <div className="tooltip-top cancel-audio-counter">
      <i
        className="far fa-times-circle fs-25 fs-sm-and-down-20 my-4 mr-7 cursor-pointer"
        onClick={() => cancelAudio()}
      />
      {onMobile === false
        && <div className="tooltiptext">Cancelar</div>}
    </div>
    <div className="time-audio-counter mt-md-1">
      <span><i className="fas fa-circle fs-sm-and-down-12 fs-15 mr-4" /></span>
      <span className="text-gray-dark fs-sm-and-down-12">
        {audioMinutes}
        :
      </span>
      <span
        className="text-gray-dark fs-sm-and-down-12"
      >
        {audioSeconds}
      </span>
    </div>
    <div className="tooltip-top send-audio-counter">
      <i
        className="far fa-check-circle fs-25 fs-sm-and-down-20 my-4 ml-7 cursor-pointer"
        onClick={() => mediaRecorder.stop()}
      />
      {onMobile === false
        && <div className="tooltiptext">Enviar</div>}
    </div>
  </div>

);

export default RecordingAudioPanel;
