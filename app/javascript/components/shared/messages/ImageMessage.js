import React, { useState, useEffect } from 'react';

function ImageMessage(props) {
  const [url, setUrl] = useState('');

  const getMsnUrl = () => {
    if (!props.message.mid) {
      setUrl(props.message.url);
      return;
    }

    FB.api(
      `/${props.message.mid}`,
      'get',
      {
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
          }
        }
      }
    );
  };

  useEffect(() => {
    if (props.chatType === 'whatsapp') {
      setUrl(props.message.content_media_url);
    } else {
      getMsnUrl();
    }
  });

  return (
    <div className="img-holder">
      <img
        src={url}
        className="msg__img"
        onClick={(e) => props.onClick(e)}
        alt=""
      />
      {props.message.is_loading && (
        <div className="lds-dual-ring" />
      )}
    </div>
  );
}

export default ImageMessage;
