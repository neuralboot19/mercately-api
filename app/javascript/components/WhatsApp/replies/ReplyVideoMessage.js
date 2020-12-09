import React from 'react';

const ReplyVideoMessage = ({ mediaUrl }) => {
  return (
    <video width="120" height="80" controls>
      <source src={mediaUrl}/>
    </video>
  )
}

export default ReplyVideoMessage;