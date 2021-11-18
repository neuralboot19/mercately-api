import React from 'react';
import stringUtils from '../../util/stringUtils';

const SelectedProductImageContainer = ({ onRemove, url }) => (
  <div className="selected-product-image-container">
    <i
      className="fas fa-times-circle cursor-pointer"
      onClick={() => onRemove()}
    />
    <img src={stringUtils.formatSelectedProductUrl(url)} />
  </div>
);

export default SelectedProductImageContainer;
