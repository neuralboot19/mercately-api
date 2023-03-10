import React, { Component } from 'react';
import RepliedMessage from '../shared/messages/replied/RepliedMessage';
import TextMessage from '../shared/messages/TextMessage';
import NoteMessage from '../shared/messages/NoteMessage';
import AudioMessage from '../shared/messages/AudioMessage';
import ContactMessage from './messages/ContactMessage';
import DocumentMessage from '../shared/messages/DocumentMessage';
import LocationMessage from '../shared/messages/LocationMessage';
import ImageMessage from '../shared/messages/ImageMessage';
import VideoMessage from '../shared/messages/VideoMessage';
import StickerMessage from './messages/StickerMessage';

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
    const isNote = this.props.message.content_type === 'text' && this.props.message.note === true;
    let textMsg;
    if (isNote) {
      textMsg = <NoteMessage
        chatType="whatsapp"
        message={this.props.message}
      />
    } else if (this.props.message.content_type === 'text') {
      textMsg = <TextMessage
        chatType="whatsapp"
        handleMessageEvents={this.props.handleMessageEvents}
        message={this.props.message}
      />
    }

    return (
      <div>
        {this.props.message.replied_message
        && (
          <RepliedMessage
            downloadFile={this.downloadFile}
            message={this.props.message.replied_message}
            openImage={this.props.openImage}
          />
        )}
        {textMsg && textMsg}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'image'
        && (
          <ImageMessage
            chatType="whatsapp"
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
            onClick={this.props.openImage}
          />
        )}
        {this.props.message.content_type === 'media'
        && (this.props.message.content_media_type === 'voice' || this.props.message.content_media_type === 'audio')
        && (
          <AudioMessage
            chatType="whatsapp"
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'video'
        && (
          <VideoMessage
            chatType="whatsapp"
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
          />
        )}
        {this.props.message.content_type === 'location'
        && (
          <LocationMessage
            chatType="whatsapp"
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'document'
        && (
          <DocumentMessage
            chatType="whatsapp"
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
            onClick={this.downloadFile}
          />
        )}
        {this.props.message.content_type === 'contact'
        && (
          <ContactMessage
            message={this.props.message}
            handleMessageEvents={this.props.handleMessageEvents}
          />
        )}
        {this.props.message.content_type === 'media'
        && this.props.message.content_media_type === 'sticker'
        && (
          <StickerMessage
            handleMessageEvents={this.props.handleMessageEvents}
            message={this.props.message}
            onClick={this.props.openImage}
          />
        )}
      </div>
    );
  }
}

export default Message;
