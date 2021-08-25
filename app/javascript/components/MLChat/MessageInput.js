import React from 'react';

const MessageInput = ({
  onKeyPress,
  getCaretPosition
}) => (
  <div
    id="divMessage"
    contentEditable="true"
    role="textbox"
    placeholder-text="Escribe tu mensaje"
    className="message-input fs-sm-and-down-12 fs-14"
    onKeyPress={onKeyPress}
    onKeyUp={getCaretPosition}
    onMouseUp={getCaretPosition}
    tabIndex="0"
  />
);
export default MessageInput;
