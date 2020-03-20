import React from "react";

const ChatMessage = ({message, toggleImgModal, downloadFile, fileType}) => {
  var tag;
  switch (fileType(message.file_type)) {
    case 'image':
      tag = <div className="img-holder">
        <img src={message.url} className="msg__img"
          onClick={(e) => toggleImgModal(e)}/>
        {message.is_loading && (
          <div class="lds-dual-ring"></div>
        )}
      </div>
        break;
    case 'audio':
      tag = <div className="w-400">
        <audio controls>
          <source src={message.url}/>
        </audio>
        {message.is_loading && (
          <div class="lds-dual-ring"></div>
        )}
      </div>
        break;
    case 'file':
        tag = <p className="fs-15"><a href="" onClick={(e) => downloadFile(e, message.url, message.filename)}><i className="fas fa-file-download mr-8"></i>{message.filename || 'Descargar archivo'}</a></p>
        {message.is_loading && (
          <div class="lds-dual-ring"></div>
        )}
        break;
    default:
      tag = <p>{message.text}</p>
  }
  return (tag)
}

export default ChatMessage;
