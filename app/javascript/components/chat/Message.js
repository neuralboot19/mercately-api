import React from "react";
import ImageMessage from '../shared/messages/ImageMessage';
import AudioMessage from '../shared/messages/AudioMessage';
import DocumentMessage from '../shared/messages/DocumentMessage';
import VideoMessage from '../shared/messages/VideoMessage';
import LocationMessage from './messages/LocationMessage';
import DefaultMessage from './messages/DefaultMessage';

const ChatMessage = ({
  message,
  toggleImgModal,
  downloadFile,
  fileType,
  timeMessage
}) => {
  let tag;
  switch (fileType(message.file_type)) {
    case 'image':
      tag = <ImageMessage message={message} onClick={toggleImgModal} />;
      break;
    case 'audio':
      tag = (
        <AudioMessage
          mediaUrl={message.url}
          isLoading={message.is_loading}
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
      tag = <div className="w-400 message-video-audio-content">
              <VideoMessage
                url={message.url}
              />
              {message.is_loading && (
                <div class="lds-dual-ring"></div>
              )}
            </div>
      break;
    case 'location':
      tag = <LocationMessage message={message} />
      break;
    default:
        tag = <DefaultMessage
          message={message}
          timeMessage={timeMessage}
        />
  }
  return (tag)
}

export default ChatMessage;
