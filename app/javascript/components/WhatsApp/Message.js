import React, { Component } from 'react';
import ReplyMessage from './replies/ReplyMessage';
import TextMessage from './messages/TextMessage';
import AudioMessage from '../shared/messages/AudioMessage';
import VideoMessage from '../shared/messages/VideoMessage';
import LocationMessage from './messages/LocationMessage';
import DocumentMessage from '../shared/messages/DocumentMessage';
import ContactMessage from './messages/ContactMessage';
import ImageMessage from '../shared/messages/ImageMessage';

class Message extends Component {
  downloadFile = (e, fileUrl, filename) => {
    e.preventDefault();
    const link = document.createElement('a');
    link.href = fileUrl;
    link.target = '_blank';
    link.download = filename;
    link.click();
  }

  render() {
    return (
      <div>
        {this.props.message.replied_message
        && (
          <ReplyMessage
            downloadFile={this.downloadFile}
            message={this.props.message.replied_message}
            toggleImgModal={this.props.toggleImgModal}
          />
        )}
        {this.props.message.content_type === 'text'
        && (
          <TextMessage
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'image'
        && (
          <ImageMessage
            chatType="whatsapp"
            message={this.props.message}
            onClick={this.props.toggleImgModal}
          />
        )}
        {this.props.message.content_type === 'media'
        && (this.props.message.content_media_type === 'voice' || this.props.message.content_media_type === 'audio')
        && (
          <AudioMessage
            mediaUrl={this.props.message.content_media_url}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'video'
        && (
          <VideoMessage
            url={this.props.message.content_media_url}
          />
        )}
        {this.props.message.content_type === 'location'
        && (
          <LocationMessage
            latitude={this.props.message.content_location_latitude}
            longitude={this.props.message.content_location_longitude}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'document'
        && (
          <DocumentMessage
            caption={this.props.message.filename}
            onClick={this.downloadFile}
            url={this.props.message.content_media_url}
          />
        )}
        {this.props.message.content_media_caption
        && (<div className="caption text-pre-line">{this.props.message.content_media_caption}</div>)}
        {this.props.message.content_type === 'contact'
        && this.props.message.contacts_information.map((contact) => (
          <ContactMessage
            key={contact.id}
            contact={contact}
          />
        ))}
      </div>
    );
  }
}

export default Message;
