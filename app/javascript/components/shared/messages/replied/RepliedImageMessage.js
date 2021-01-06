import React from 'react';

const RepliedImageMessage = ({ mediaUrl, onClick }) => (
  <img
    src={mediaUrl}
    className="image"
    onClick={(e) => onClick(e)}
  />
);

export default RepliedImageMessage;
