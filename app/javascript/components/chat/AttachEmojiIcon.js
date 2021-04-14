import React from 'react';

const AttachEmojiIcon = ({
  onMobile,
  toggleEmojiPicker
}) => (
  <div className="tooltip-top">
    <i
      className="fas fa-smile fs-22 ml-7 mr-7 cursor-pointer"
      onClick={toggleEmojiPicker}
    >
    </i>
    {onMobile === false && (
      <div className="tooltiptext">Emojis</div>
    )}
  </div>
);

export default AttachEmojiIcon;
