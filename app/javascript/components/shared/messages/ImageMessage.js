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
  const [error, setError] = useState(false);

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

  const errorLoadingImg = (e) => {
    if (url) setError(true);
  };

  useEffect(() => {
    if (chatType === 'whatsapp') {
      setUrl(formatUrl(message.content_media_url));
    } else {
      getMsnUrl();
    }
  }, []);

  const formatUrl = (originalUrl) => {
    const formats = 'if_w_gt_300/c_scale,w_300/if_end/q_auto';
    return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
  }

  const formatUrlZoom = (originalUrl) => {
    if (chatType !== 'whatsapp') return originalUrl;

    const formats = 'if_w_gt_1000/c_scale,w_1000/if_end';
    return originalUrl.replace('if_w_gt_300/c_scale,w_300/if_end', `${formats}`);
  }

  return (
    <div className="img-holder">
      <div>
        <div className={ error ? 'media-content error-media-content' : 'media-content' }>
          {message.is_loading && (
            <div className="lds-dual-ring" />
          )}
          { error ? (
            <blockquote className="text-center mt-140 c-black">
              Imagen temporal no disponible
            </blockquote>
          ) : (
            <img
              src={url}
              className="msg__img"
              onClick={() => onClick(formatUrlZoom(url))}
              onError={errorLoadingImg}
              alt=""
              style={{display: "block"}}
            />
          ) }
          <MediaMessageStatus
            chatType={chatType}
            message={message}
            handleMessageEvents={handleMessageEvents}
            mediaMessageType="image"
          />
        </div>
        {caption
        && (<div className="media-caption text-pre-line t-left fs-md-and-down-12" dangerouslySetInnerHTML={{ __html: checkForUrls(caption) }} />)}
      </div>
    </div>
  );
}

export default ImageMessage;
