import React from 'react';

const MobileHeader = ({ onBack }) => (
  <div
    className="c-secondary fs-15 mt-12"
    onClick={() => onBack()}
  >
    <i className="fas fa-chevron-left c-secondary">
    </i>
    &nbsp;&nbsp;volver
  </div>
);

export default MobileHeader;
