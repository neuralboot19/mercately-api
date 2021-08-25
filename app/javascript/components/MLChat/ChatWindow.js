import React from 'react';

import ChatMessage from './ChatMessage';
import MessageForm from './MessageForm';

const ChatWindow = ({
  state,
  handleScrollToTop,
  bottomRef,
  openImage,
  handleSubmitMessage
}) => {
  let caretPosition = 0;

  const divClasses = (message) => {
    let classes = message.answer ? 'message-by-retailer f-right' : 'message-by-customer text-gray-dark';
    classes += ' main-message-container';
    return classes;
  };

  const fileType = (fileTypeArg) => {
    if (fileTypeArg == null) {
      return fileTypeArg;
    } else if (fileTypeArg.includes('image/') || fileTypeArg === 'image') {
      return 'image';
    }

    return 'file';
  };

  const downloadFile = (e, fileUrl, filename) => {
    e.preventDefault();
    const link = document.createElement('a');
    link.href = fileUrl;
    link.download = filename;
    link.click();
  };

  const getCaretPosition = () => {
    let sel;
    let range;
    const editableDiv = document.getElementById('divMessage');
    editableDiv.normalize();

    if (window.getSelection) {
      sel = window.getSelection();

      if (sel.rangeCount) {
        range = sel.getRangeAt(0);

        if (range.commonAncestorContainer.parentNode === editableDiv) {
          caretPosition = range.endOffset;
        }
      }
    } else if (document.selection && document.selection.createRange) {
      range = document.selection.createRange();

      if (range.parentElement() === editableDiv) {
        const tempEl = document.createElement("span");
        editableDiv.insertBefore(tempEl, editableDiv.firstChild);

        const tempRange = range.duplicate();
        tempRange.moveToElementText(tempEl);
        tempRange.setEndPoint("EndToEnd", range);

        caretPosition = tempRange.text.length;
      }
    }
  };

  const insertEmoji = (emoji) => {
    const input = $('#divMessage');
    let text = input.text();
    const first = text.substring(0, caretPosition);
    const second = text.substring(caretPosition);

    if (text.length === 0) caretPosition = 0;

    text = (first + emoji.native + second);
    input.html(text);

    setFocus(caretPosition + emoji.native.length);
  };

  const setFocus = (position) => {
    const node = document.getElementById("divMessage");
    let caret = 0;
    const input = $(node);
    const text = input.text();

    node.focus();

    if (position) {
      caret = position;
    } else {
      caret = text.length;
    }

    if (caret > 0) {
      const range = document.createRange();
      let dynamicCaret = caret;
      node.childNodes.forEach((textNode) => {
        if (dynamicCaret <= textNode.length) {
          range.setStart(textNode, dynamicCaret);
          range.setEnd(textNode, dynamicCaret);
          return;
        }
        dynamicCaret -= textNode.length;
      });

      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }

    caretPosition = caret;
  };

  return (
    <>
      <div className="col-xs-12 border-12 ml-chat__box pt-8" onScroll={handleScrollToTop}>
        {state.orderMessages.map((message) => (
          <div key={message.id} className="message">
            <div className={divClasses(message)}>
              <ChatMessage
                message={message}
                downloadFile={downloadFile}
                fileType={fileType}
                openImage={openImage}
                mlOrderId={state.selectedOrder.meli_order_id}
              />
            </div>
          </div>
        ))}
        <div id="bottomRef" ref={bottomRef}></div>
      </div>
      { state.selectedOrder.status === 'pending' && (
        <div className="col-xs-12 chat-input">
          <MessageForm
            handleSubmitMessage={handleSubmitMessage}
            getCaretPosition={getCaretPosition}
            insertEmoji={insertEmoji}
          />
        </div>
      ) }
      { state.selectedOrder.status === 'success' && (
        <div className="col-xs-12">
          Esta orden ha sido completada, no puedes enviar mensajes
        </div>
      ) }
      { state.selectedOrder.status === 'cancelled' && (
        <div className="col-xs-12">
          Esta orden ha sido cancelada, no puedes enviar mensajes
        </div>
      ) }
    </>
  );
};

export default ChatWindow;
