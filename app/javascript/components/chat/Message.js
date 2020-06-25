import React from "react";

const ChatMessage = ({message, toggleImgModal, downloadFile, fileType}) => {
  var tag;
  switch (fileType(message.file_type)) {
    case 'image':
      tag = <div className="img-holder">
              <img src={message.url} className="msg__img" onClick={(e) => toggleImgModal(e)}/>
              {message.is_loading && (
                <div class="lds-dual-ring"></div>
              )}
            </div>
      break;
    case 'audio':
      tag = <div className="w-400 message-video-audio-content">
              <audio controls>
                <source src={message.url}/>
              </audio>
              {message.is_loading && (
                <div class="lds-dual-ring"></div>
              )}
            </div>
      break;
    case 'file':
        tag = <p className="fs-15">
                <a href="" onClick={(e) => downloadFile(e, message.url, message.filename)}>
                  <i className="fas fa-file-download mr-8"></i>{message.filename || 'Descargar archivo'}
                </a>
              </p>
              {message.is_loading && (
                <div class="lds-dual-ring"></div>
              )}
        break;
    case 'video':
      tag = <div className="w-400 message-video-audio-content">
              <video width="320" height="240" controls>
                <source src={message.url}/>
              </video>
              {message.is_loading && (
                <div class="lds-dual-ring"></div>
              )}
            </div>
      break;
    case 'location':
      tag = <p className="fs-15">
              <a href={message.url} target="_blank">
                <i className="fas fa-map-marker-alt mr-8"></i>Ver ubicación
              </a>
            </p>
      break;
    default:
        tag = <p className={ message.sent_by_retailer == true && message.date_read ? 'read-message' : '' }>{message.text} {
          message.sent_by_retailer == true && message.date_read && (
              <i className="fas fa-check-double"></i>
          )}</p>
  }
  return (tag)
}

export default ChatMessage;
