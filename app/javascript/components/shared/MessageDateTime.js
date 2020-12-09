import React from 'react';
import moment from 'moment';

const MessageDateTime = ({ chatType, message }) => {
  const messageDateTime = chatType === "whatsapp" ? message.created_time : message.created_at;

  const messageDirection = () => {
    if ((chatType === "whatsapp" && message.direction === 'inbound')
      || message.sent_by_retailer === false) {
      return "inbound";
    }
    return false;
  };

  const messageDateTimeClass = messageDirection() === "inbound" ? 'fs-10 mt-3 c-gray-label' : 'fs-10 mt-3';

  const formattedDateTime = moment(messageDateTime).local().locale('es').format('DD-MM-YYYY HH:mm');

  return (
    <span
      className={messageDateTimeClass}
    >
      {formattedDateTime}
    </span>
  );
};

export default MessageDateTime;
