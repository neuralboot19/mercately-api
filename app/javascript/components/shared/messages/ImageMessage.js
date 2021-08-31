import React, { useState, useEffect } from 'react';
import MediaMessageStatus from '../MediaMessageStatus';
import checkForUrls from "../../../util/urlUtil";

function ImageMessage({
  chatType,
  handleMessageEvents,
  message,
  onClick
}) {
  const caption = chatType === 'facebook' ? message.text : message.content_media_caption;

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
  }, []);

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
            onClick={() => onClick(url)}
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
        {caption
        && (<div className="media-caption text-pre-line t-left" dangerouslySetInnerHTML={{ __html: checkForUrls(caption) }} />)}
      </div>
    </div>
  );
}

export default ImageMessage;
