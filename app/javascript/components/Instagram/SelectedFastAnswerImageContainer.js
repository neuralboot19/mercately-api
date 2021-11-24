import React from 'react';
import stringUtils from '../../util/stringUtils';

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
    <img src={stringUtils.formatSelectedFastAnswerUrl(selectedFastAnswer.attributes.image_url)}>
    </img>
  </div>
);

export default SelectedFastAnswerImageContainer;
