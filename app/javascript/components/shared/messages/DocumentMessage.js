import React, { useState, useEffect } from 'react';
import MessageStatus from '../MessageStatus';

// chatType, handleMessageEvents, isReply, message, onClick
function DocumentMessage(props) {
  const caption = props.chatType === 'facebook' ? props.message.text : props.message.content_media_caption;
  const auxUrl = props.chatType === 'facebook' ? props.message.url : props.message.content_media_url;

  const [url, setUrl] = useState(auxUrl);
  const [error, setError] = useState(false);

  const getMsnUrl = () => {
    if (!props.message.mid) {
      setUrl(props.message.url);
      return;
    }

    // eslint-disable-next-line no-undef
    FB.api(
      `/${props.message.mid}`,
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
              && response.attachments.data[0]) {
            setUrl(response.attachments.data[0].file_url);
          }
        }
      }
    );
  };

  useEffect(() => {
    if (props.chatType === 'whatsapp') {
      setUrl(props.message.content_media_url);
      if (props.message.direction === 'outbound') tryUrl();
    } else {
      getMsnUrl();
    }
  }, []);

  const tryUrl = () => {
    if (url === window.location.href) return;

    fetch(url).then((resp) => {
      if (!resp.ok) {
        setError(true);
      }
    });
  };

  return (
    (props.isLoading ? (
      <div className="lds-dual-ring" />
    ) : (
      <div className={`fs-15 ${props.isReply ? 'no-back-color' : ''}`}>
        { error ? (
          <>
            <i className="far fa-file-excel mr-8 fs-15"></i><span className="fs-14">{ 'Archivo no disponible' }</span>
          </>
        ) : (
          <a
            href=""
            onClick={(e) => props.onClick(e, url, props.message.filename)}
            className="fs-md-and-down-12"
          >
            <i className="fas fa-file-download mr-8" />
            {props.message.filename || 'Descargar archivo'}
          </a>
        )}
        <br />
        {caption
        && (<div className="media-caption media-caption-template text-pre-line fs-md-and-down-12">{caption}</div>)}
        <MessageStatus
          chatType={props.chatType}
          handleMessageEvents={props.handleMessageEvents}
          message={props.message}
        />
      </div>
    ))
  );
}

export default DocumentMessage;
