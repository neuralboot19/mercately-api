import React from 'react';
import PdfIcon from 'images/pdf_icon.png'

const SelectedFastAnswerImageContainer = ({
  selectedFastAnswer,
  removeSelectedFastAnswer
}) => {
  let url = selectedFastAnswer.attributes.image_url;
  if (selectedFastAnswer.attributes.file_type === 'file') url = PdfIcon;

  return (
    <div className="selected-product-image-container">
      <i
        className="fas fa-times-circle cursor-pointer"
        onClick={removeSelectedFastAnswer}
      >
      </i>
      <img src={url} />
    </div>
  );
};

export default SelectedFastAnswerImageContainer;
