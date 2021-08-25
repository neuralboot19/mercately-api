import React from 'react';
import PropTypes from 'prop-types';

import MessageDateTime from './MessageDateTime';
import MessageStatusIcon from './MessageStatusIcon';
import SenderData from './SenderData';

const MediaMessageStatus = ({
  chatType,
  message,
  handleMessageEvents,
  mediaMessageType
}) => {
  const shouldShowIcon = () => {
    if (chatType === "whatsapp"
      && message.direction === 'outbound'
      && handleMessageEvents === true) {
      return true;
    }
    return (message.sent_by_retailer === true && message.date_read);
  };

  const getClassName = () => {
    switch (mediaMessageType) {
      case "video":
      case "image":
        return "img-video-message-status";
      case "audio":
        return "audio-message-status";
      default:
        return "";
    }
  };

  return (
    <div className={getClassName()}>
      <MessageDateTime
        chatType={chatType}
        message={message}
      />
      {shouldShowIcon() && (
        <MessageStatusIcon
          chatType={chatType}
          message={message}
        />
      )}
      {message.sender_full_name && (
        <SenderData
          senderFullName={message.sender_full_name}
        />
      )}
    </div>
  );
};

MediaMessageStatus.propTypes = {
  chatType: PropTypes.string,
  message: PropTypes.shape({
    id: PropTypes.number.isRequired,
    retailer_id: PropTypes.number,
    customer_id: PropTypes.number.isRequired,
    status: PropTypes.string,
    direction: PropTypes.string.isRequired,
    channel: PropTypes.string,
    message_type: PropTypes.string.isRequired,
    uid: PropTypes.string.isRequired,
    created_time: PropTypes.string.isRequired,
    replied_message: PropTypes.string,
    filename: PropTypes.string,
    content_type: PropTypes.string.isRequired,
    content_text: PropTypes.string,
    content_media_url: PropTypes.string,
    content_media_caption: PropTypes.string,
    content_media_type: PropTypes.string.isRequired,
    content_location_longitude: PropTypes.string,
    content_location_latitude: PropTypes.string,
    content_location_label: PropTypes.string,
    content_location_address: PropTypes.string,
    account_uid: PropTypes.string.isRequired,
    contacts_information: PropTypes.arrayOf(
      PropTypes.shape({
        names: PropTypes.shape({
          first_name: PropTypes.string,
          formatted_name: PropTypes.string
        }),
        phones: PropTypes.arrayOf({
          phone: PropTypes.string,
          type: PropTypes.string
        }),
        emails: PropTypes.arrayOf(PropTypes.string),
        addresses: PropTypes.arrayOf(PropTypes.string),
        org: PropTypes.objectOf(PropTypes.string)
      })
    )
  }).isRequired,
  handleMessageEvents: PropTypes.bool,
  mediaMessageType: PropTypes.oneOf(['video', 'image', 'audio']).isRequired
};

MediaMessageStatus.defaultProps = {
  chatType: "",
  handleMessageEvents: false
};

export default MediaMessageStatus;
