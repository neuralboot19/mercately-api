import React from 'react';
import MessageStatus from '../MessageStatus';
import checkForUrls from "../../../util/urlUtil";

const PostMessage = ({ chatType, handleMessageEvents, message }) => {
  const formatText = (text) => text?.replace(/~([^~\n]*[^~\s])~/g, '<s>$1</s>')
    .replace(/_([^_\n]*[^_\s])_/g, '<i>$1</i>')
    .replace(/\*([^*\n]*[^*\s])\*/g, '<b>$1</b>')
    .replace(/`{3}([^`\n]*[^`\s])`{3}/g, '<pre class="d-inline-block">$1</pre>');

  let messageText = message.text;
  messageText = formatText(messageText);
  messageText = checkForUrls(messageText);
  const { url } = message;

  return (
    <div className="text-pre-line">
      <a href={url} target="_blank">{url}</a>
      <div dangerouslySetInnerHTML={{ __html: messageText }} />
      <MessageStatus
        chatType={chatType}
        handleMessageEvents={handleMessageEvents}
        message={message}
      />
    </div>
  );
};

export default PostMessage;
