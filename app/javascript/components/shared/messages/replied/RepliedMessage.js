import React from 'react';
import ReplyTextMessage from './ReplyTextMessage';
import RepliedImageMessage from './RepliedImageMessage';
import RepliedAudioMessage from './RepliedAudioMessage';
import RepliedDocumentMessage from './RepliedDocumentMessage';
import RepliedLocationMessage from './RepliedLocationMessage';
import RepliedContactMessage from './RepliedContactMessage';
import RepliedVideoMessage from './RepliedVideoMessage';

const RepliedMessage = ({
  chatType,
  downloadFile,
  message,
  openImage
}) => {
  const isText = () => message.data.attributes.content_type === 'text';

  const isImage = () => (
    message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'image'
  );

  const isAudio = () => (
    message.data.attributes.content_type === 'media'
    && (message.data.attributes.content_media_type === 'voice'
      || message.data.attributes.content_media_type === 'audio')
  );

  const isVideo = () => (
    message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'video'
  );

  const isLocation = () => message.data.attributes.content_type === 'location';

  const isDocument = () => (
    message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'document'
  );

  const isContact = () => message.data.attributes.content_type === 'contact';

  return (
    <div className="replied-message mb-10">
      {isText()
      && (
        <ReplyTextMessage
          text={message.data.attributes.content_text}
        />
      )}
      {isImage()
      && (
        <RepliedImageMessage
          mediaUrl={message.data.attributes.content_media_url}
          onClick={openImage}
        />
      )}
      {isAudio()
      && (
        <RepliedAudioMessage
          url={message.data.attributes.content_media_url}
        />
      )}
      {isVideo()
      && (
        <RepliedVideoMessage
          url={message.data.attributes.content_media_url}
        />
      )}
      {isLocation()
      && (
        <RepliedLocationMessage
          latitude={message.data.attributes.content_location_latitude}
          longitude={message.data.attributes.content_location_longitude}
        />
      )}
      {isDocument()
      && (
        <RepliedDocumentMessage
          chatType={chatType}
          message={message.data.attributes}
          isReply
          onClick={downloadFile}
        />
      )}
      {isContact()
      && message.data.attributes.contacts_information.map((contact) => (
        <RepliedContactMessage
          key={contact.id}
          contact={contact}
        />
      ))}
    </div>
  );
};

export default RepliedMessage;
