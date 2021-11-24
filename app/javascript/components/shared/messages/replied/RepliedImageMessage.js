import React from 'react';

const RepliedImageMessage = ({ mediaUrl, onClick }) => (
  <img
    src={formatUrl(mediaUrl)}
    className="image"
    onClick={() => onClick(mediaUrl)}
  />
);

const formatUrl = (originalUrl) => {
  const formats = 'c_scale,w_100/q_auto';
  return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
}

export default RepliedImageMessage;
