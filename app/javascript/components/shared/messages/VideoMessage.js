import React from 'react';

const VideoMessage = ({ isReply, url }) => {
  const width = isReply ? 120 : 320;
  const height = isReply ? 80 : 240;
  return (
    <video width={width} height={height} controls>
      <source src={url} />
    </video>
  );
};

export default VideoMessage;
