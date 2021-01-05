import React from 'react';
import MessageStatus from "../MessageStatus";
import MediaMessageStatus from "../MediaMessageStatus";

const AudioMessage = ({
  chatType,
  handleMessageEvents,
  message
}) => {
  const url = chatType === 'whatsapp' ? message.content_media_url : message.url;

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
        <audio controls className="d-block">
          <source src={url} />
        </audio>
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
