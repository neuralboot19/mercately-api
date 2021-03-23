import React from 'react';
import MessageDateTime from './MessageDateTime';
import MessageStatusIcon from './MessageStatusIcon';

const MessageStatus = ({
  chatType,
  handleMessageEvents,
  message
}) => {
  const shouldShowIcon = () => {
    if (chatType === "whatsapp"
      && message.direction === 'outbound'
      && handleMessageEvents === true) {
      return true;
    }
    return (message.sent_by_retailer === true && message.date_read);
  };

  return (
    <div className="f-right t-right">
      <MessageDateTime
        chatType={chatType}
        message={message}
      />
      {shouldShowIcon() && (
        <MessageStatusIcon
          chatType={chatType}
          message={message}
        />
      )}
    </div>
  );
};

export default MessageStatus;
