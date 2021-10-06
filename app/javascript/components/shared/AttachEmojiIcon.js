import React from 'react';
import PickEmojiOutlineIcon from '../icons/PickEmojiOutlineIcon';

const AttachEmojiIcon = ({
  onMobile,
  toggleEmojiPicker
}) => (
  <div className="tooltip-top" onClick={toggleEmojiPicker}>
    <PickEmojiOutlineIcon
      className="fill-icon-input cursor-pointer"
    />
    {onMobile === false && (
      <div className="tooltiptext">Emojis</div>
    )}
  </div>
);

export default AttachEmojiIcon;
