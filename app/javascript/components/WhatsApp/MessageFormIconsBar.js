import React from 'react';
import EmojisContainer from './EmojisContainer';
import AttachFileIcon from '../icons/AttachFileOutlineIconContainer';
import AttachImageIcon from '../icons/AttachImageOutlineIconContainer';
import RecordAudioIcon from '../icons/RecordAudioOutlineIconContainer';
import PickEmojiIcon from '../icons/PickEmojiOutlineIconContainer';
import SendButton from './SendButton';
import RecordingAudioPanel from './RecordingAudioPanel';

const MessageFormIconsBar = (
  {
    allowSendVoice,
    audioMinutes,
    audioSeconds,
    cancelAudio,
    handleFileSubmit,
    handleSubmit,
    insertEmoji,
    mediaRecorder,
    onMobile,
    recordAudio,
    recordingAudio,
    showEmojiPicker,
    toggleEmojiPicker,
    toggleLoadImages
  }
) => (
  <div className="t-right d-flex justify-content-end">
    {
      recordingAudio ? (
        <RecordingAudioPanel
          audioMinutes={audioMinutes}
          audioSeconds={audioSeconds}
          cancelAudio={cancelAudio}
          mediaRecorder={mediaRecorder}
          onMobile={onMobile}
        />
      ) : (
        <div className="p-relative d-flex align-items-center space-input-icons">
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
          {
              // eslint-disable-next-line no-undef
            ENV.INTEGRATION === '1'
            && allowSendVoice
            && <RecordAudioIcon onMobile={onMobile} recordAudio={recordAudio} />
          }
          <AttachImageIcon onMobile={onMobile} toggleLoadImages={toggleLoadImages} />
          <PickEmojiIcon onMobile={onMobile} toggleEmojiPicker={toggleEmojiPicker} />
          <SendButton handleSubmit={handleSubmit} onMobile={onMobile} />
        </div>
      )
    }
  </div>
);

export default MessageFormIconsBar;
