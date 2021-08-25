import React from 'react';

const MessageInput = ({ getCaretPosition, onKeyPress, pasteImages }) => (
  <div
    id="divMessage"
    contentEditable="true"
    role="textbox"
    placeholder-text="Escribe tu mensaje"
    className="message-input fs-input-text"
    onPaste={(e) => pasteImages(e)}
    onKeyPress={onKeyPress}
    onKeyUp={getCaretPosition}
    onMouseUp={getCaretPosition}
    tabIndex="0"
  />

);
export default MessageInput;
