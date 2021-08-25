import React from 'react';
import MessageDateTime from './MessageDateTime';
import MessageStatusIcon from './MessageStatusIcon';
import SenderData from './SenderData';

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
    <>
      <div className="text-right">
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
      {message.sender_full_name && (
        <SenderData
          senderFullName={message.sender_full_name}
        />
      )}
    </>
  );
};

export default MessageStatus;
