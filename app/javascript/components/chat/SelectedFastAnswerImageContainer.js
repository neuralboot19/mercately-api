import React from 'react';

const SelectedFastAnswerImageContainer = ({
  selectedFastAnswer,
  removeSelectedFastAnswer
}) => (
  <div className="selected-product-image-container">
    <i
      className="fas fa-times-circle cursor-pointer"
      onClick={removeSelectedFastAnswer}
    >
    </i>
    <img src={selectedFastAnswer.attributes.image_url}>
    </img>
  </div>
);

export default SelectedFastAnswerImageContainer;
