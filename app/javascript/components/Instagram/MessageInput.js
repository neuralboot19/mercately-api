import React from 'react';

const MessageInput = ({
  pasteImages,
  onKeyPress,
  getCaretPosition
}) => (
  <div
    id="divMessage"
    contentEditable="true"
    role="textbox"
    placeholder-text="Escribe un mensaje aquí"
    className="message-input fs-14"
    onPaste={(e) => pasteImages(e)}
    onKeyPress={onKeyPress}
    onKeyUp={getCaretPosition}
    onMouseUp={getCaretPosition}
    tabIndex="0"
  >
  </div>
);
export default MessageInput;
