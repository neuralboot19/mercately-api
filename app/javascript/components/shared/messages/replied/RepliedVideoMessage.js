import React from 'react';

const RepliedVideoMessage = ({ url }) => (
  <div className="video-content">
    <video width={120} height={80} controls>
      <source src={url} />
    </video>
  </div>
);

export default RepliedVideoMessage;
