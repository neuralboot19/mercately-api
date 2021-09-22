import React from "react";
import checkForUrls from "../../util/urlUtil";
import formatText from "../../util/textUtil";
import MessageDateTime from '../shared/MessageDateTime';

const ChatMessage = ({
  message,
  downloadFile,
  fileType,
  openImage,
  mlOrderId
}) => {
  const showAttachment = (attachment) => {
    const url = `https://www.mercadolibre.${ENV.ML_DOMAIN}/compras/mensajeria/${mlOrderId}/${ENV.ML_ID}/attachment/${attachment.filename}`;
    switch (fileType(attachment.type)) {
      case 'image':
        return (
          <div className="img-holder">
            <div>
              <div className="media-content">
                <img
                  src={url}
                  className="msg__img"
                  onClick={() => openImage(url)}
                  alt=""
                  style={{ display: "block" }}
                />
              </div>
            </div>
          </div>
        );
      default:
        return (
          <div className="fs-15">
            <a
              href=""
              target="_blank"
              onClick={(e) => downloadFile(e, url, attachment.filename)}
            >
              <i className="fas fa-file-download mr-8" />
              {attachment.original_filename || 'Descargar archivo'}
            </a>
          </div>
        );
    }
  };

  let messageText = message.question || message.answer;
  messageText = formatText(messageText) || '';
  messageText = checkForUrls(messageText);

  return (
    <div className="text-pre-line">
      <div dangerouslySetInnerHTML={{ __html: messageText }} />
      {(message.attachments && message.attachments.map((attachment) => (
        showAttachment(attachment)
      )))}
      <div className="text-right">
        <MessageDateTime message={message} />
      </div>
    </div>
  );
};

export default ChatMessage;
