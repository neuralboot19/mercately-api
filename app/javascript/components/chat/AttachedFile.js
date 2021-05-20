import React from 'react';

const AttachedFile = ({ handleFileSubmit }) => (
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
);

export default AttachedFile;
