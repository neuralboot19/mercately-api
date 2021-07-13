import React from 'react';
import PickEmojiOutlineIcon from '../icons/PickEmojiOutlineIcon'

const PickEmojiIcon = ({ onMobile, toggleEmojiPicker }) => (
  <div className="tooltip-top" onClick={() => toggleEmojiPicker()}>
    <PickEmojiOutlineIcon
      className="fill-icon-input cursor-pointer"
    />
    {/* <i
      className="fas fa-microphone fs-22 ml-7 mr-7 cursor-pointer"
      onClick={() => recordAudio()}
    /> */}
    {onMobile === false
      && <div className="tooltiptext">Emojis</div>}
  </div>
);

export default PickEmojiIcon;
