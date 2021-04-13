import React from 'react';

const RepliedStickerMessage = ({ mediaUrl, onClick }) => (
  <img
    src={mediaUrl}
    className="image"
    onClick={() => onClick(mediaUrl)}
  />
);

export default RepliedStickerMessage;
