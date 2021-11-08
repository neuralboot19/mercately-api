import React from 'react';
import PdfIcon from 'images/pdf_icon.png'

const SelectedFastAnswerImageContainer = ({ onRemove, url, fileType }) => {
  let fileUrl = url;
  if (fileType === 'file') fileUrl = PdfIcon;

  return (
    <div className="selected-product-image-container">
      <i
        className="fas fa-times-circle cursor-pointer"
        onClick={() => onRemove()}
      />
      <img src={fileUrl} />
    </div>
  );
};

export default SelectedFastAnswerImageContainer;
