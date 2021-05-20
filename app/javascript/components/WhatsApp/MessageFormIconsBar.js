import React from 'react';
import EmojisContainer from './EmojisContainer';
import AttachFileIcon from './AttachFileIcon';
import AttachImageIcon from './AttachImageIcon';
import SelectFastAnswerIcon from './SelectFastAnswerIcon';
import SelectProductIcon from './SelectProductIcon';
import AttachLocationIcon from './AttachLocationIcon';
import RecordAudioIcon from './RecordAudioIcon';
import PickEmojiIcon from './PickEmojiIcon';
import SendButton from './SendButton';
import RecordingAudioPanel from './RecordingAudioPanel';
import ReminderIcon from './ReminderIcon';

const MessageFormIconsBar = (
  {
    allowSendVoice,
    audioMinutes,
    audioSeconds,
    cancelAudio,
    getLocation,
    handleFileSubmit,
    handleSubmit,
    insertEmoji,
    mediaRecorder,
    onMobile,
    recordAudio,
    recordingAudio,
    showEmojiPicker,
    toggleEmojiPicker,
    toggleFastAnswers,
    toggleLoadImages,
    toggleProducts,
    openReminderConfigModal
  }
) => (
  <div className="t-right mr-15">
    {
        !recordingAudio
        && (
        <div className="p-relative">
          {
            showEmojiPicker
            && <EmojisContainer insertEmoji={insertEmoji} />
          }
          <input
            id="attach-file"
            className="d-none"
            type="file"
            name="messageFile"
            accept={"application/pdf, application/msword, "
            + "application/vnd.openxmlformats-officedocument.wordprocessingml.document, "
            + "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, "
            + "application/vnd.ms-excel"}
            onChange={(e) => handleFileSubmit(e)}
          />
          <AttachFileIcon onMobile={onMobile} />
          <AttachImageIcon onMobile={onMobile} toggleLoadImages={toggleLoadImages} />
          <SelectFastAnswerIcon onMobile={onMobile} toggleFastAnswers={toggleFastAnswers} />
          <SelectProductIcon onMobile={onMobile} toggleProducts={toggleProducts} />
          <AttachLocationIcon getLocation={getLocation} onMobile={onMobile} />
          {
              // eslint-disable-next-line no-undef
            ENV.INTEGRATION === '1'
            && allowSendVoice
            && <RecordAudioIcon onMobile={onMobile} recordAudio={recordAudio} />
          }
          <PickEmojiIcon onMobile={onMobile} toggleEmojiPicker={toggleEmojiPicker} />
            <ReminderIcon onMobile={onMobile} openReminderConfigModal={openReminderConfigModal} />
          <div className="tooltip-top ml-15" />
          <SendButton handleSubmit={handleSubmit} onMobile={onMobile} />
        </div>
        )
      }
    {
        recordingAudio
        && (
        <RecordingAudioPanel
          audioMinutes={audioMinutes}
          audioSeconds={audioSeconds}
          cancelAudio={cancelAudio}
          mediaRecorder={mediaRecorder}
          onMobile={onMobile}
        />
        )
      }
  </div>
);

export default MessageFormIconsBar;
