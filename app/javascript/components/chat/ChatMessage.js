import React from "react";
import ImageMessage from '../shared/messages/ImageMessage';
import AudioMessage from '../shared/messages/AudioMessage';
import DocumentMessage from '../shared/messages/DocumentMessage';
import VideoMessage from '../shared/messages/VideoMessage';
import LocationMessage from '../shared/messages/LocationMessage';
import TextMessage from '../shared/messages/TextMessage';

const ChatMessage = ({
  message,
  toggleImgModal,
  downloadFile,
  fileType
}) => {
  let tag;
  switch (fileType(message.file_type)) {
    case 'image':
      tag = (
        <ImageMessage
          message={message}
          onClick={toggleImgModal}
        />
      );
      break;
    case 'audio':
      tag = (
        <AudioMessage
          message={message}
        />
      );
      break;
    case 'file':
      tag = (
        <DocumentMessage
          isLoading={message.is_loading}
          message={message}
          onClick={downloadFile}
        />
      );
      break;
    case 'video':
      tag = (
        <VideoMessage
          message={message}
        />
      );
      break;
    case 'location':
      tag = (
        <LocationMessage
          message={message}
        />
      );
      break;
    default:
      tag = (
        <TextMessage
          message={message}
        />
      );
  }
  return (tag);
};

export default ChatMessage;
