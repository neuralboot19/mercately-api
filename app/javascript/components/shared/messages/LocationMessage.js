import React from 'react';
import MessageStatus from '../MessageStatus';

const LocationMessage = ({ chatType, handleMessageEvents, message }) => {
  const latitude = message.content_location_latitude;
  const longitude = message.content_location_longitude;
  const locationURL = () => {
    if (chatType === "whatsapp") {
      return `https://www.google.com/maps/place/
                      ${latitude},
                      ${longitude}`;
    }
    return message.url || message.text;
  };

  return (
    <div className="fs-md-and-down-12">
      <a
        href={locationURL()}
        target="_blank"
      >
        <i className="fas fa-map-marker-alt mr-8" />
        Ver ubicación
      </a>
      <br />
      <MessageStatus
        chatType={chatType}
        message={message}
        handleMessageEvents={handleMessageEvents}
      />
    </div>
  );
};

export default LocationMessage;
