import React from 'react';

const SelectedProductImageContainer = ({
  removeSelectedProduct,
  selectedProduct
}) => (
  <div className="selected-product-image-container">
    <i className="fas fa-times-circle cursor-pointer" onClick={() => removeSelectedProduct()}/>
    <img src={selectedProduct.attributes.image}/>
  </div>
);

export default SelectedProductImageContainer;
