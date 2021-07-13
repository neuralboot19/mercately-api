import React from 'react';
import DoubleCheckIcon from '../icons/DoubleCheckIcon';
import CheckIcon from '../icons/CheckIcon';

const MessageStatusIcon = ({
  chatType,
  message
}) => {
  const iconClass = () => {
    let className;
    switch (message.status) {
      case 'error':
        className = 'exclamation-circle fs-12 ml-4';
        break;
      case 'sent':
        return <CheckIcon className="fill-gray ml-4" />;
      case 'delivered':
        return <DoubleCheckIcon className="fill-gray ml-4" />;
      case 'read':
        return <DoubleCheckIcon className="fill-blue ml-4" />;
      default:
        className = message.content_type === 'text' ? 'check' : 'sync';
    }
    return <CheckIcon className="fill-gray ml-4" />;
  };

  return chatType === 'whatsapp'
    ? (
      <>
        {iconClass()}
        {message.status === 'error' && (
          <>
            <br />
            <small>{message.error_message}</small>
          </>
        )}
      </>
    )
    : <DoubleCheckIcon className="fill-blue ml-4" />;
};

export default MessageStatusIcon;
