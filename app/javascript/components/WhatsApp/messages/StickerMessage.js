import React, { useState, useEffect } from 'react';
import MediaMessageStatus from '../../shared/MediaMessageStatus';

function StickerMessage({
  handleMessageEvents,
  message,
  onClick
}) {
  const [url, setUrl] = useState('');

  useEffect(() => {
    setUrl(message.content_media_url);
  }, [message.content_media_url]);

  return (
    <div className="img-holder">
      <div>
        <div className="media-content">
          {message.is_loading && (
            <div className="lds-dual-ring" />
          )}
          <img
            src={url}
            className="msg__img d-block"
            onClick={() => onClick(url)}
            alt=""
          />
          <MediaMessageStatus
            chatType="whatsapp"
            message={message}
            handleMessageEvents={handleMessageEvents}
            mediaMessageType="image"
          />
        </div>
        {message.content_media_caption
        && (<div className="media-caption text-pre-line">{message.content_media_caption}</div>)}
      </div>
    </div>
  );
}

export default StickerMessage;
