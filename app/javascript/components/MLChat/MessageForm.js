import React, { useState } from 'react';
import 'emoji-mart/css/emoji-mart.css';
import MessageInput from './MessageInput';
import EmojisContainer from '../chat/EmojisContainer';
import AttachEmojiIcon from '../chat/AttachEmojiIcon';
import SendButton from '../chat/SendButton';

const MessageForm = ({
  handleSubmitMessage,
  getCaretPosition,
  insertEmoji
}) => {
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);

  const handleSubmit = (e) => {
    const input = $('#divMessage');
    const text = input.text();
    if (text.trim() === '') return;

    const txt = getText();
    handleSubmitMessage(e, txt);

    setShowEmojiPicker(false);
    input.html(null);
  };

  const onKeyPress = (e) => {
    if (e.which === 13 && e.shiftKey && e.target.innerText.trim() === "") e.preventDefault();
    if (e.which === 13 && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  const getText = () => {
    const input = $('#divMessage');
    const txt = input.html();

    return txt.replace(/<br>/g, "\n")
      .replace(/&amp;/g, '&');
  };

  const toggleEmojiPicker = () => {
    setShowEmojiPicker(!showEmojiPicker);
  };

  return (
    <div className="text-input">
      <MessageInput
        onKeyPress={onKeyPress}
        getCaretPosition={getCaretPosition}
      />
      <div className="t-right mr-15 p-relative">
        {showEmojiPicker
        && (
          <EmojisContainer insertEmoji={insertEmoji} />
        )}
        <AttachEmojiIcon toggleEmojiPicker={toggleEmojiPicker} />
        <div className="tooltip-top ml-15" />
        <SendButton handleSubmit={handleSubmit} />
      </div>
    </div>
  );
};

export default MessageForm;
