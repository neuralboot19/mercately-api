import React from 'react';
import MediaMessageStatus from '../MediaMessageStatus';
import checkForUrls from "../../../util/urlUtil";

const VideoMessage = ({ chatType, handleMessageEvents, message }) => {
  const caption = chatType === 'facebook' ? message.text : message.content_media_caption;

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
      {caption
      && (<div className="media-caption text-pre-line" dangerouslySetInnerHTML={{ __html: checkForUrls(caption) }} />)}
    </div>
  );
};

export default VideoMessage;
