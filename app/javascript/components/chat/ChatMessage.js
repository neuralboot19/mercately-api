import React from "react";
import ImageMessage from '../shared/messages/ImageMessage';
import AudioMessage from '../shared/messages/AudioMessage';
import DocumentMessage from '../shared/messages/DocumentMessage';
import VideoMessage from '../shared/messages/VideoMessage';
import PostMessage from '../shared/messages/PostMessage';
import LocationMessage from '../shared/messages/LocationMessage';
import TextMessage from '../shared/messages/TextMessage';
import NoteMessage from '../shared/messages/NoteMessage';

const ChatMessage = ({
  message,
  downloadFile,
  fileType,
  openImage
}) => {
  let tag;
  switch (fileType(message.file_type)) {
    case 'image':
      tag = (
        <ImageMessage
          message={message}
          onClick={openImage}
          chatType="facebook"
        />
      );
      break;
    case 'audio':
      tag = (
        <AudioMessage
          message={message}
          chatType="facebook"
        />
      );
      break;
    case 'file':
      tag = (
        <DocumentMessage
          isLoading={message.is_loading}
          message={message}
          onClick={downloadFile}
          chatType="facebook"
        />
      );
      break;
    case 'video':
      tag = (
        <VideoMessage
          message={message}
          chatType="facebook"
        />
      );
      break;
    case 'fallback':
      tag = (
        <PostMessage
          message={message}
          chatType="facebook"
        />
      );
      break;
    case 'location':
      tag = (
        <LocationMessage
          message={message}
          chatType="facebook"
        />
      );
      break;
    default:
      if (message.note === true) {
        tag = (
          <NoteMessage
            chatType="facebook"
            message={message}
          />
        );
      } else {
        tag = (
          <TextMessage
            chatType="facebook"
            message={message}
          />
        );
      }
  }
  return (tag);
};

export default ChatMessage;
