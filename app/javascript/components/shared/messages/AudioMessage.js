import React, { useState } from 'react';
import MessageStatus from "../MessageStatus";
import MediaMessageStatus from "../MediaMessageStatus";

const AudioMessage = ({
  chatType,
  handleMessageEvents,
  message
}) => {
  const url = chatType === 'whatsapp' ? message.content_media_url : message.url;
  const [error, setError] = useState(false);

  const onError = () => {
    setError(true);
  };

  if (message.is_loading) {
    return (
      <div className="message-video-audio-content">
        <div className="lds-dual-ring" />
      </div>
    );
  }
  return (
    <div className="message-video-audio-content">
      <div className="message-video-audio-content audio-content">
        { error ? (
          <div className="c-black">
            <i className="fas fa-volume-mute mr-8 fs-15"></i><span>{ 'Audio no disponible' }</span>
          </div>
        ) : (
          <audio controls className="d-block" onError={onError}>
            <source src={url} />
          </audio>
        )}
        <MediaMessageStatus
          chatType={chatType}
          handleMessageEvents={handleMessageEvents}
          message={message}
          mediaMessageType="audio"
        />
      </div>
    </div>
  );
};

export default AudioMessage;
