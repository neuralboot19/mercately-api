import React from 'react';

const DefaultMessage = ({ message, timeMessage }) => (
  <div className="text-pre-line">
    {message.text}
    <br />
    <div className="f-right">
      {timeMessage(message)}
      {
        message.sent_by_retailer === true && message.date_read && (
          <i className="ml-7 fas fa-check-double checks-mark" />
        )
      }
    </div>
  </div>
);

export default DefaultMessage;
