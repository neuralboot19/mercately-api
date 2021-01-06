import React, { useState, useEffect } from 'react';
import MessageStatus from '../MessageStatus';

// chatType, handleMessageEvents, isReply, message, onClick
function DocumentMessage(props) {
  const [url, setUrl] = useState('');

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
    } else {
      getMsnUrl();
    }
  });

  return (
    (props.isLoading ? (
      <div className="lds-dual-ring" />
    ) : (
      <div className={`fs-15 ${props.isReply ? 'no-back-color' : ''}`}>
        <a
          href=""
          onClick={(e) => props.onClick(e, url, props.message.filename)}
        >
          <i className="fas fa-file-download mr-8" />
          {props.message.filename || 'Descargar archivo'}
        </a>
        <br />
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
