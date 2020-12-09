import React from 'react';

const LocationMessage = ({ message }) => (
  <div className="fs-15">
    <a href={message.url || message.text} target="_blank">
      <i className="fas fa-map-marker-alt mr-8" />
      Ver ubicación
    </a>
  </div>
);
export default LocationMessage;
