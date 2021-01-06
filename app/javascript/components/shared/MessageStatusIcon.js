import React from 'react';

const MessageStatusIcon = ({
  chatType,
  message
}) => {
  const iconClass = () => {
    let className;
    switch (message.status) {
      case 'sent':
        className = 'check';
        break;
      case 'delivered':
        className = 'check-double';
        break;
      case 'read':
        className = 'check-double stroke';
        break;
      default:
        className = 'sync';
    }
    return `checks-mark ml-7 fas fa-${className}`;
  };
  if (chatType === "whatsapp") {
    return <i className={iconClass()} />;
  }
  return <i className="ml-7 fas fa-check-double checks-mark" />;
};

export default MessageStatusIcon;
