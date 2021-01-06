import React from 'react';
import MessageStatus from '../MessageStatus';

const TextMessage = ({ chatType, handleMessageEvents, message }) => {
  const messageText = chatType === "whatsapp" ? message.content_text : message.text;

  return (
    <div className="text-pre-line">
      {messageText}
      <br />
      <MessageStatus
        chatType={chatType}
        handleMessageEvents={handleMessageEvents}
        message={message}
      />
    </div>
  );
};

export default TextMessage;
