import React from 'react';

const RepliedImageMessage = ({ mediaUrl, onClick }) => (
  <img
    src={mediaUrl}
    className="image"
    onClick={() => onClick(mediaUrl)}
  />
);

export default RepliedImageMessage;
