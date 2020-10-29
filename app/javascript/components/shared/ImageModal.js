import React from 'react';

const ImageModal = ({ toggleImgModal, url }) => {
  return (
    <div className="img_modal">
      <div className="img_modal__overlay" onClick={(e) => toggleImgModal(e)}>
      </div>
      <img src={url}/>
    </div>
  )

}

export default ImageModal;
