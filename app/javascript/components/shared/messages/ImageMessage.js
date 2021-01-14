import React, { useState, useEffect } from 'react';
import MediaMessageStatus from '../MediaMessageStatus';

function ImageMessage({
  chatType,
  handleMessageEvents,
  message,
  onClick
}) {
  const [url, setUrl] = useState('');

  const getMsnUrl = () => {
    if (!message.mid) {
      setUrl(message.url);
      return;
    }

    // eslint-disable-next-line no-undef
    FB.api(
      `/${message.mid}`,
      'get',
      {
        // eslint-disable-next-line no-undef
        access_token: ENV.FANPAGE_TOKEN,
        fields: 'message, attachments'
      },
      (response) => {
        if (response && !response.error) {
          if (response.attachments
              && response.attachments.data
              && response.attachments.data[0]
              && response.attachments.data[0].image_data) {
            setUrl(response.attachments.data[0].image_data.url);
          } else {
            setUrl(message.url);
          }
        }
      }
    );
  };

  useEffect(() => {
    if (chatType === 'whatsapp') {
      setUrl(message.content_media_url);
    } else {
      getMsnUrl();
    }
  });

  return (
    <div className="img-holder">
      <div>
        <div className="media-content">
          {message.is_loading && (
            <div className="lds-dual-ring" />
          )}
          <img
            src={url}
            className="msg__img"
            onClick={(e) => onClick(e)}
            alt=""
            style={{display: "block"}}
          />
          <MediaMessageStatus
            chatType={chatType}
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

export default ImageMessage;
