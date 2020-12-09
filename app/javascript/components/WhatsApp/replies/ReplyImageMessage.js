import React from 'react';


const ReplyImageMessage = ({ mediaUrl, onClick }) => {

  return (
    <img src={mediaUrl}
         className="image"
         onClick={(e) => onClick(e)}/>
  )
}

export default ReplyImageMessage;