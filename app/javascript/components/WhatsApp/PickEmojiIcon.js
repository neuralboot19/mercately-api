import React from 'react';

const PickEmojiIcon = ({ onMobile, toggleEmojiPicker }) => (
  <div className="tooltip-top">
    <i
      className="fas fa-smile fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => toggleEmojiPicker()}
    />
    {onMobile === false
      && <div className="tooltiptext">Emojis</div>}
  </div>
);

export default PickEmojiIcon;
