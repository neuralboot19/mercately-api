import React from 'react';

const AudioMessage = ({ isLoading, mediaUrl }) => (
  <div className="message-video-audio-content">
    {isLoading
      ? <div className="lds-dual-ring" />
      : (
        <audio controls>
          <source src={mediaUrl} />
        </audio>
      )}
  </div>
);

export default AudioMessage;
