import React, { useState, useEffect } from 'react';

function RepliedDocumentMessage({
  chatType,
  isLoading,
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
              && response.attachments.data[0]) {
            setUrl(response.attachments.data[0].file_url);
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

  if (isLoading) {
    return <div className="lds-dual-ring" />;
  }
  return (
    <div className="fs-md-and-down-12 no-back-color">
      <a
        href=""
        onClick={(e) => onClick(e, url, message.filename)}
      >
        <i className="fas fa-file-download mr-8" />
        {message.filename || 'Descargar archivo'}
      </a>
    </div>
  );
}

export default RepliedDocumentMessage;
