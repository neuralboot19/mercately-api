import React from 'react';

const RepliedLocationMessage = ({ latitude, longitude }) => {
  const locationURL = `https://www.google.com/maps/place/
                      ${latitude},
                      ${longitude}`;

  return (
    <div className="fs-15 no-back-color">
      <a
        href={locationURL}
        target="_blank"
      >
        <i className="fas fa-map-marker-alt mr-8" />
        Ver ubicación
      </a>
      <br />
    </div>
  );
};

export default RepliedLocationMessage;
