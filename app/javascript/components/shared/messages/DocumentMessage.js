import React from 'react';

const DocumentMessage = ({
  isLoading,
  caption,
  isReply,
  onClick,
  url
}) => (isLoading ? (
  <div className="lds-dual-ring" />
) : (
  <div className={`fs-15 ${isReply ? 'no-back-color' : ''}`}>
    <a
      href=""
      onClick={(e) => onClick(e, url, caption)}
    >
      <i className="fas fa-file-download mr-8" />
      {caption || 'Descargar archivo'}
    </a>
  </div>
));

export default DocumentMessage;
