import React from 'react';
import MessageStatus from '../MessageStatus';
import checkForUrls from "../../../util/urlUtil";

const NoteMessage = ({ chatType, message }) => {
  const formatText = (text) => text?.replace(/~([^~\n]*[^~\s])~/g, '<s>$1</s>')
    .replace(/_([^_\n]*[^_\s])_/g, '<i>$1</i>')
    .replace(/\*([^*\n]*[^*\s])\*/g, '<b>$1</b>')
    .replace(/`{3}([^`\n]*[^`\s])`{3}/g, '<pre class="d-inline-block">$1</pre>');

  let messageText = chatType === "whatsapp" ? message.content_text : message.text;
  messageText = formatText(messageText);
  messageText = checkForUrls(messageText);

  return (
    <div className="text-pre-line">
      <div dangerouslySetInnerHTML={{ __html: messageText }} />
      <MessageStatus
        chatType={chatType}
        handleMessageEvents={false}
        message={message}
      />
    </div>
  );
};

export default NoteMessage;
