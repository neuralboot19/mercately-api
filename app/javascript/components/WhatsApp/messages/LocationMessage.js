import React from 'react';

const LocationMessage = ({ isReply, latitude, longitude }) => (
  <div className={`fs-15 ${isReply ? 'no-back-color' : ''}`}>
    <a
      href={`https://www.google.com/maps/place/${latitude},${longitude}`}
      target="_blank"
    >
      <i className="fas fa-map-marker-alt mr-8" />
      Ver ubicación
    </a>
  </div>
);
export default LocationMessage;
