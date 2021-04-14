import React from 'react';

const AttachedFile = ({ handleFileSubmit }) => (
  <input
    id="attach-file"
    className="d-none"
    type="file"
    name="messageFile"
    accept="application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    onChange={(e) => handleFileSubmit(e)}
  />
);

export default AttachedFile;
