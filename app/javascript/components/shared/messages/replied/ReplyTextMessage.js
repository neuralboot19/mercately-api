import React from 'react';
import checkForUrls from "../../../../util/urlUtil";

const ReplyTextMessage = ({ text }) => {
  const formatText = (baseText) => baseText?.replace(/~([^~\n]*[^~\s])~/g, '<s>$1</s>')
    .replace(/_([^_\n]*[^_\s])_/g, '<i>$1</i>')
    .replace(/\*([^*\n]*[^*\s])\*/g, '<b>$1</b>')
    .replace(/`{3}([^`\n]*[^`\s])`{3}/g, '<pre class="d-inline-block">$1</pre>');

  let messageText = formatText(text);
  messageText = checkForUrls(messageText);

  return (
    <div className="text text-pre-line fs-md-and-down-12" dangerouslySetInnerHTML={{ __html: messageText }} />
  );
};

export default ReplyTextMessage;
