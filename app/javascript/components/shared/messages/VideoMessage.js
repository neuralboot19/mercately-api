import React from 'react';
import MediaMessageStatus from '../MediaMessageStatus';
import checkForUrls from "../../../util/urlUtil";

const VideoMessage = ({ chatType, handleMessageEvents, message }) => {
  const url = chatType === "whatsapp" ? message.content_media_url : message.url;

  return (
    <div>
      <div className="video-content">
        <video width={320} height={240} controls className="d-block">
          <source src={url} />
        </video>
        <MediaMessageStatus
          chatType={chatType}
          message={message}
          handleMessageEvents={handleMessageEvents}
          mediaMessageType="video"
        />
      </div>
      {message.content_media_caption
      && (<div className="media-caption text-pre-line" dangerouslySetInnerHTML={{ __html: checkForUrls(message.content_media_caption) }} />)}
    </div>
  );
};

export default VideoMessage;
