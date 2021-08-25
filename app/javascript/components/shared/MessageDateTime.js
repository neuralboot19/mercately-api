import React from 'react';
import moment from 'moment';

const MessageDateTime = ({ chatType, message }) => {
  let messageDateTime = chatType === "whatsapp" ? message.created_time : message.created_at;
  if (!messageDateTime) messageDateTime = message.date_created_question || message.date_created_answer;

  const messageDirection = () => {
    if ((chatType === "whatsapp" && message.direction === 'inbound')
      || message.sent_by_retailer === false) {
      return "inbound";
    }
    return false;
  };

  const messageDateTimeClass = messageDirection() === "inbound" ? 'fs-10 mt-3' : 'mt-3';

  const formattedDateTime = moment(messageDateTime).local().locale('es').format('DD-MM-YYYY HH:mm');

  return (
    <div className="d-inline fs-10">
      <span
        className={messageDateTimeClass}
      >
        {formattedDateTime}
      </span>
    </div>
  );
};

export default MessageDateTime;
