import React, { useState } from 'react';
import MediaMessageStatus from '../MediaMessageStatus';
import checkForUrls from "../../../util/urlUtil";

const VideoMessage = ({ chatType, handleMessageEvents, message }) => {
  const caption = chatType === 'facebook' ? message.text : message.content_media_caption;
  const url = chatType === "whatsapp" ? message.content_media_url : message.url;

  const [error, setError] = useState(false);

  const errorLoadingVideo = () => {
    if (url) setError(true);
  };

  return (
    <div className={error ? 'error-media-content' : ''}>
      <div className="video-content">
        { error ? (
          <blockquote className="text-center py-115 c-black">
            Video temporal no disponible
          </blockquote>
        ) : (
          <video width={320} height={240} onError={errorLoadingVideo} controls className="d-block">
            <source src={url} />
          </video>
        ) }
        <MediaMessageStatus
          chatType={chatType}
          message={message}
          handleMessageEvents={handleMessageEvents}
          mediaMessageType="video"
        />
      </div>
      {caption
      && (<div className="media-caption text-pre-line fs-md-and-down-12" dangerouslySetInnerHTML={{ __html: checkForUrls(caption) }} />)}
    </div>
  );
};

export default VideoMessage;
