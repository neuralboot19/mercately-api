import React from 'react';

const ImageMessage = ({ chatType, message, onClick }) => {
  const url = chatType === 'whatsapp' ? message.content_media_url : message.url;

  return (
    <div className="img-holder">
      <img
        src={url}
        className="msg__img"
        onClick={(e) => onClick(e)}
        alt=""
      />
      {message.is_loading && (
        <div className="lds-dual-ring" />
      )}
    </div>
  );
};

export default ImageMessage;
