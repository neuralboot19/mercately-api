import React from 'react';

const SelectedFastAnswerImageContainer = ({ onRemove, url }) => (
  <div className="selected-product-image-container">
    <i
      className="fas fa-times-circle cursor-pointer"
      onClick={() => onRemove()}
    />
    <img src={url} />
  </div>
);

export default SelectedFastAnswerImageContainer;
