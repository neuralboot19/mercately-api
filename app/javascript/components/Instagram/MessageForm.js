import React, { useEffect, useState } from "react";
import 'emoji-mart/css/emoji-mart.css';
// eslint-disable-next-line import/no-unresolved
import PlusOutlineIcon from 'images/plusOutline.svg';
import MessageInput from "./MessageInput";
import SelectedProductImageContainer from "./SelectedProductImageContainer";
import SelectedFastAnswerImageContainer from "./SelectedFastAnswerImageContainer";
import EmojisContainer from "./EmojisContainer";
import AttachedFile from "./AttachedFile";
import AttachFileIcon from "./AttachFileIcon";
import AttachImageIcon from "../icons/AttachImageOutlineIconContainer";
import AttachFastAnswerIcon from "./AttachFastAnswerIcon";
import AttachEmojiIcon from "./AttachEmojiIcon";
import MessageInputMenu from '../shared/MessageInputMenu';
import SendButton from "./SendButton";

const MessageForm = ({
  handleSubmitMessage,
  handleSubmitImg,
  toggleMap,
  objectPresence,
  pasteImages,
  getCaretPosition,
  selectedProduct,
  removeSelectedProduct,
  selectedFastAnswer,
  removeSelectedFastAnswer,
  insertEmoji,
  onMobile,
  toggleLoadImages,
  toggleFastAnswers,
  toggleProducts,
  showInputMenu,
  handleShowInputMenu
}) => {
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);

  const handleSubmit = (e) => {
    const input = $('#divMessage');
    const text = input.text();
    if (text.trim() === '' && selectionPresent() === false) return;

    const txt = getText();
    handleSubmitMessage(e, txt);

    setShowEmojiPicker(false);
    input.html(null);
  };

  const handleFileSubmit = (e) => {
    const el = e.target;
    const file = el.files[0];

    if (![
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel'
    ].includes(file.type)) {
      alert('Error: El archivo debe ser de tipo PDF, Excel o Word');
      return;
    }

    // Max 20 Mb allowed
    if (file.size > 20 * 1024 * 1024) {
      alert('Error: Maximo permitido 20MB');
      return;
    }

    const data = new FormData();
    data.append('file_data', file);
    handleSubmitImg(el, data);
    $('#attach-file')
      .val('');
  };

  const onKeyPress = (e) => {
    if (e.which === 13 && e.shiftKey && e.target.innerText.trim() === "") e.preventDefault();
    if (e.which === 13 && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  useEffect(() => {
    if (selectedFastAnswer) {
      $('#divMessage')
        .html(selectedFastAnswer.attributes.answer);
    }
  }, [selectedFastAnswer]);

  useEffect(() => {
    if (selectedProduct) {
      let productString = '';
      productString += (`${selectedProduct.attributes.title}\n`);
      productString += (`Precio $${selectedProduct.attributes.price}\n`);
      productString += (`${selectedProduct.attributes.description}\n`);
      productString += (selectedProduct.attributes.url ? selectedProduct.attributes.url : '');
      $('#divMessage')
        .html(productString);
    }
  }, [selectedProduct]);

  const getText = () => {
    const input = $('#divMessage');
    const txt = input.html();

    return txt.replace(/<br>/g, "\n")
      .replace(/&amp;/g, '&');
  };

  const selectionPresent = () => objectPresence();

  const getLocation = () => {
    handleShowInputMenu();
    if (navigator.geolocation) {
      toggleMap();
    } else {
      alert('La geolocalización no está soportada en este navegador');
    }
  };

  const toggleEmojiPicker = () => {
    setShowEmojiPicker(!showEmojiPicker);
  };

  return (
    <div className="col-xs-12 chat-input mt-16">
      <div className="text-input row mx-0 no-gutters text-input-padding border-input-top">
        <div className="d-flex col-7 col-md-8">
          <span className="d-flex align-items-center position-relative mr-12 mr-md-24 min-w-input-menu">
            <img onClick={handleShowInputMenu} src={PlusOutlineIcon} alt="outline plus icon" />
            {showInputMenu && (
              <MessageInputMenu
                handleShowInputMenu={handleShowInputMenu}
                getLocation={getLocation}
                openProducts={toggleProducts}
              />
            )}
          </span>
          <span className="bg-light border-left-8 flex-grow-1">
            <MessageInput
              pasteImages={pasteImages}
              onKeyPress={onKeyPress}
              getCaretPosition={getCaretPosition}
            />
          </span>
          {selectedProduct
          && selectedProduct.attributes.image
          && (
            <SelectedProductImageContainer
              removeSelectedProduct={removeSelectedProduct}
              selectedProduct={selectedProduct}
            />
          )}
          {/* selectedFastAnswer
          && selectedFastAnswer.attributes.image_url
          && (
            <SelectedFastAnswerImageContainer
              selectedFastAnswer={selectedFastAnswer}
              removeSelectedFastAnswer={removeSelectedFastAnswer}
            />
          ) */}
        </div>
        <div className="col-5 col-md-4 bg-light border-right-8 d-flex">
          <div className="p-relative flex-grow-1 pr-8 d-flex justify-content-end align-items-center  space-input-icons">
            {showEmojiPicker
            && (
              <EmojisContainer insertEmoji={insertEmoji} />
            )}
            {/* <AttachedFile handleFileSubmit={handleFileSubmit} /> */}
            {/* <AttachFileIcon onMobile={onMobile} /> */}
            <AttachImageIcon onMobile={onMobile} toggleLoadImages={toggleLoadImages} />
            {/* <AttachFastAnswerIcon onMobile={onMobile} toggleFastAnswers={toggleFastAnswers} /> */}
            <AttachEmojiIcon onMobile={onMobile} toggleEmojiPicker={toggleEmojiPicker} />
            <SendButton onMobile={onMobile} handleSubmit={handleSubmit} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default MessageForm;
