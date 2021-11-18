import React from 'react';
import stringUtils from '../../util/stringUtils';

const SelectedProductImageContainer = ({
  removeSelectedProduct,
  selectedProduct
}) => (
  <div className="selected-product-image-container">
    <i className="fas fa-times-circle cursor-pointer" onClick={() => removeSelectedProduct()}/>
    <img src={stringUtils.formatSelectedProductUrl(selectedProduct.attributes.image)}/>
  </div>
);

export default SelectedProductImageContainer;
