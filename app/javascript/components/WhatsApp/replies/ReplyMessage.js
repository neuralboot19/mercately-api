import React from 'react';
import ReplyTextMessage from './ReplyTextMessage';
import ReplyImageMessage from './ReplyImageMessage';
import AudioMessage from '../../shared/messages/AudioMessage';
import ContactMessage from '../messages/ContactMessage';
import DocumentMessage from '../../shared/messages/DocumentMessage';
import LocationMessage from '../messages/LocationMessage';
import VideoMessage from '../../shared/messages/VideoMessage';

const ReplyMessage = ({ downloadFile, message, toggleImgModal }) => (
  <div className="replied-message mb-10">
    {message.data.attributes.content_type === 'text'
    && <ReplyTextMessage text={message.data.attributes.content_text} />}
    {message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'image'
    && (
      <ReplyImageMessage
        mediaUrl={message.data.attributes.content_media_url}
        onClick={toggleImgModal}
      />
    )}
    {message.data.attributes.content_type === 'media'
    && (message.data.attributes.content_media_type === 'voice'
      || message.data.attributes.content_media_type === 'audio')
    && (
      <AudioMessage mediaUrl={message.data.attributes.content_media_url} />
    )}
    {message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'video'
    && (
      <VideoMessage isReply url={message.data.attributes.content_media_url} />
    )}
    {message.data.attributes.content_type === 'location' && (
      <LocationMessage
        isReply
        latitude={message.data.attributes.content_location_latitude}
        longitude={message.data.attributes.content_location_longitude}
      />
    )}
    {message.data.attributes.content_type === 'media'
    && message.data.attributes.content_media_type === 'document'
    && (
      <DocumentMessage
        caption={message.data.attributes.content_media_caption}
        isReply
        onClick={downloadFile}
        url={message.data.attributes.content_media_url}
      />
    )}
    {message.data.attributes.content_type === 'contact'
    && message.data.attributes.contacts_information.map((contact) => (
      <ContactMessage key={contact.id} contact={contact} isReply />
    ))}
  </div>
);

export default ReplyMessage;
