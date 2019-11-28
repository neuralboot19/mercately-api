import React from "react";

import CustomerMessage from './CustomerMessage';
import RetailerMessage from './RetailerMessage';

const ChatMessage = ({ message }) => {
  let messageComponent;
  if (message.sent_by_retailer == true) {
    messageComponent = <RetailerMessage message={message}/>
  } else {
    messageComponent = <CustomerMessage message={message}/>
  }
  return (
    <div>
      {messageComponent}
    </div>
  )
}

export default ChatMessage;
