import React from 'react';

const RepliedAudioMessage = ({ url }) => (
  <div className="message-video-audio-content">
    <div className="message-video-audio-content audio-content">
      <audio controls className="d-block">
        <source src={url} />
      </audio>
    </div>
  </div>
);

export default RepliedAudioMessage;
