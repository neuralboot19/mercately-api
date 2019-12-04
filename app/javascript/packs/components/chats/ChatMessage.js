import React from "react";

import CustomerMessage from './CustomerMessage';
import RetailerMessage from './RetailerMessage';

const ChatMessage = ({ message }) => {
  let messageComponent;
  if (message.sent_by_retailer == true) {
    messageComponent = <RetailerMessage message={message.text}/>
  } else {
    messageComponent = <CustomerMessage message={message.text}/>
  }
  return (
    <div>
      {messageComponent}
    </div>
  )
}

export default ChatMessage;
