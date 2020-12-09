import React from 'react';

const TextMessage = ({ handleMessageEvents, message }) => {
  const timeMessage = () => {
    return (
      <span
        className={message.direction === 'inbound' ? 'fs-10 mt-3 c-gray-label' : 'fs-10 mt-3'}>
        {moment(message.created_time).local().locale('es').format('DD-MM-YYYY HH:mm')}
      </span>
    )
  }
  return (
    <div className="text-pre-line">
      {message.content_text}
      <br />
      <div className="f-right">
        {timeMessage()}
        {message.direction === 'outbound' && handleMessageEvents === true &&
        <i className={ `checks-mark ml-7 fas fa-${
          message.status === 'sent' ? 'check stroke' : (message.status === 'delivered' ? 'check-double stroke' : ( message.status === 'read' ? 'check-double read' : 'sync'))
        }`
        }></i>
        }
      </div>
    </div>
  )
}

export default TextMessage;
