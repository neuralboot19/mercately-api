import React from 'react';
import MessageInput from './MessageInput';
import SelectedProductImageContainer from './SelectedProductImageContainer';
import SelectedFastAnswerImageContainer from './SelectedFastAnswerImageContainer';
import MessageFormIconsBar from './MessageFormIconsBar';

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
  toggleProducts,
  openReminderConfigModal,
  allowReminders
}) => (
  <div className="col-xs-12 chat-input">
    <div className="text-input">
      <MessageInput
        getCaretPosition={getCaretPosition}
        onKeyPress={onKeyPress}
        pasteImages={pasteImages}
      />
      {selectedProduct
      && selectedProduct.attributes.image
      && (
        <SelectedProductImageContainer
          onRemove={removeSelectedProduct}
          url={selectedProduct.attributes.image}
        />
      )}
      {selectedFastAnswer && selectedFastAnswer.attributes.image_url
      && (
        <SelectedFastAnswerImageContainer
          onRemove={removeSelectedFastAnswer}
          url={selectedFastAnswer.attributes.image_url}
        />
      )}
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
        toggleProducts={toggleProducts}
        openReminderConfigModal={openReminderConfigModal}
        allowReminders={allowReminders}
      />
    </div>
  </div>
);

export default MessageForm;
