import React from 'react';

const ReplyTextMessage = ({ text }) => {
  const formatText = (baseText) => baseText?.replace(/~([^~\n]*[^~\s])~/g, '<s>$1</s>')
    .replace(/_([^_\n]*[^_\s])_/g, '<i>$1</i>')
    .replace(/\*([^*\n]*[^*\s])\*/g, '<b>$1</b>')
    .replace(/`{3}([^`\n]*[^`\s])`{3}/g, '<pre class="d-inline-block">$1</pre>');

  const messageText = formatText(text);

  return (
    <span className="text text-pre-line">
      {messageText}
    </span>
  );
};

export default ReplyTextMessage;
