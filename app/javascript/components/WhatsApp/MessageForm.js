import React from 'react';
// eslint-disable-next-line import/no-unresolved
import PlusOutlineIcon from 'images/plusOutline.svg';
import MessageInput from './MessageInput';
import SelectedProductImageContainer from './SelectedProductImageContainer';
import SelectedFastAnswerImageContainer from './SelectedFastAnswerImageContainer';
import MessageFormIconsBar from './MessageFormIconsBar';
import MessageInputMenu from '../shared/MessageInputMenu';
import FastAnswerButton from '../shared/FastAnswerButton';
import RemindersButton from '../shared/RemindersButton';

const MessageForm = ({
  allowSendVoice,
  audioMinutes,
  audioSeconds,
  cancelAudio,
  getCaretPosition,
  getLocation,
  handleFileSubmit,
  handleSubmit,
  insertEmoji,
  mediaRecorder,
  onKeyPress,
  onMobile,
  pasteImages,
  recordAudio,
  recordingAudio,
  removeSelectedFastAnswer,
  removeSelectedProduct,
  selectedFastAnswer,
  selectedProduct,
  showEmojiPicker,
  toggleEmojiPicker,
  toggleFastAnswers,
  toggleLoadImages,
  openProducts,
  openReminderConfigModal,
  showInputMenu,
  handleShowInputMenu
}) => (
  <div className="col-xs-12 chat-input mt-16">    
    <FastAnswerButton toggleFastAnswers={toggleFastAnswers} />
    <RemindersButton openReminderConfigModal={openReminderConfigModal} />
    <div className="text-input row mx-0 no-gutters text-input-padding border-input-top">
      <div className="d-flex col-7 col-md-8">
        <span className="d-flex align-items-center position-relative mr-12 mr-md-24 min-w-input-menu">
          <img onClick={handleShowInputMenu} src={PlusOutlineIcon} alt="outline plus icon" />
          {showInputMenu && (
            <MessageInputMenu
              handleShowInputMenu={handleShowInputMenu}
              getLocation={getLocation}
              openProducts={openProducts}
            />
          )}
        </span>
        <span className="bg-light border-left-8 flex-grow-1">
          <MessageInput
            getCaretPosition={getCaretPosition}
            onKeyPress={onKeyPress}
            pasteImages={pasteImages}
          />
        </span>
        {selectedProduct
        && selectedProduct.attributes.image
        && (
          <span className="bg-light">
            <SelectedProductImageContainer
              onRemove={removeSelectedProduct}
              url={selectedProduct.attributes.image}
            />
          </span>
        )}
        {selectedFastAnswer && selectedFastAnswer.attributes.image_url
        && (
          <span className="bg-light">
            <SelectedFastAnswerImageContainer
              onRemove={removeSelectedFastAnswer}
              url={selectedFastAnswer.attributes.image_url}
            />
          </span>
        )}
      </div>
      <div className="col-5 col-md-4 bg-light border-right-8 d-flex align-items-center pr-8">
        <div className="flex-grow-1">
          <MessageFormIconsBar
            allowSendVoice={allowSendVoice}
            audioMinutes={audioMinutes}
            audioSeconds={audioSeconds}
            cancelAudio={cancelAudio}
            getLocation={getLocation}
            handleFileSubmit={handleFileSubmit}
            handleSubmit={handleSubmit}
            insertEmoji={insertEmoji}
            mediaRecorder={mediaRecorder}
            onMobile={onMobile}
            recordAudio={recordAudio}
            recordingAudio={recordingAudio}
            showEmojiPicker={showEmojiPicker}
            toggleEmojiPicker={toggleEmojiPicker}
            toggleFastAnswers={toggleFastAnswers}
            toggleLoadImages={toggleLoadImages}
          />
        </div>
      </div>
    </div>
  </div>
);

export default MessageForm;
