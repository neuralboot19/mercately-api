import React from "react";

const ChatMessage = ({message}) => {
  var tag;
  switch (message.file_type) {
    case 'image':
      tag = <div className="img-holder">
        <img src={message.url} className="msg__img"
          onClick={(e) => this.toggleImgModal(e)}/>
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
    default:
      tag = <p>{message.text}</p>
  }
  return (tag)
}

export default ChatMessage;
