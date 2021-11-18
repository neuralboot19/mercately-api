import React from 'react';
import PdfIcon from 'images/pdf_icon.png'
import stringUtils from '../../util/stringUtils';

const SelectedFastAnswerImageContainer = ({ onRemove, url, fileType }) => {
  let fileUrl = url;
  if (fileType === 'file') fileUrl = PdfIcon;

  return (
    <div className="selected-product-image-container">
      <i
        className="fas fa-times-circle cursor-pointer"
        onClick={() => onRemove()}
      />
      <img src={stringUtils.formatSelectedFastAnswerUrl(fileUrl, fileType)} />
    </div>
  );
};

export default SelectedFastAnswerImageContainer;
