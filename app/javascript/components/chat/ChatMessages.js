import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import {
  fetchMessages,
  sendMessage,
  sendImg,
  setMessageAsRead,
  sendBulkFiles
} from "../../actions/actions";

import {
  changeCustomerAgent,
  setNoRead,
  toggleChatBot
} from "../../actions/whatsapp_karix";

import MessageForm from './MessageForm';
import ChatMessage from './ChatMessage';
import ImagesSelector from "../shared/ImagesSelector";
import GoogleMap from "../shared/Map";
import TopChatBar from './TopChatBar';
import AlreadyAssignedChatLabel from '../shared/AlreadyAssignedChatLabel';
import MobileTopChatBar from '../shared/MobileTopChatBar';
import Lightbox from 'react-image-lightbox';
import { v4 as uuidv4 } from 'uuid';
import 'react-image-lightbox/style.css';

var currentCustomer = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content

class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
      load_more: false,
      page: 1,
      messages: [],
      new_message: false,
      scrolable: false,
      agents: [],
      selectedProduct: null,
      showLoadImages: false,
      loadedImages: [],
      selectedFastAnswer: null,
      showMap: false,
      zoomLevel: 17,
      isOpenImage: false,
      imageUrl: null
    };
    this.bottomRef = React.createRef();
    this.caretPosition = 0;
  }

  handleLoadMore = () => {
    let id = this.props.currentCustomer;
    if (this.props.total_pages > this.state.page) {
      this.setState({ page: this.state.page += 1, load_more: true, scrolable: false}, () => {
        this.props.fetchMessages(id, this.state.page);
      });
    }
  }

  handleSubmitMessage = (e, message) => {
    e.preventDefault();
    const uuid = uuidv4();
    let text = { message: message, message_identifier: uuid };
    let isText = message && message.trim() !== '';
    this.setState(
      {
        messages: isText ? this.state.messages.concat({
          text: message,
          sent_by_retailer: true,
          created_at: new Date(),
          message_identifier: uuid
        }) : this.state.messages,
        new_message: true
      }, () => {
        if (isText) {
          this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
        }
        this.scrollToBottom();

        if (this.objectPresence()) {
          this.handleSubmitImg();
        } else {
          this.setState({ selectedProduct: null, selectedFastAnswer: null });
          $('#divMessage').html(null);
        }
      }
    );

    this.setFocus();
  }

  handleSubmitImg = (el, file_data) => {
    let url, type, data;
    const uuid = uuidv4();

    if (this.state.selectedProduct || this.state.selectedFastAnswer) {
      url = this.state.selectedProduct ? this.state.selectedProduct.attributes.image : this.state.selectedFastAnswer.attributes.image_url;
      type = 'image';

      data = new FormData();
      data.append('url', url);
      data.append('type', 'image');
      data.append('message_identifier', uuid);
    } else {
      url = URL.createObjectURL(el.files[0]);
      type = this.fileType(el.files[0].type);
      file_data.append('message_identifier', uuid);
    }

    this.setState({
      messages: this.state.messages.concat({
        url: url,
        sent_by_retailer: true,
        file_type: type, filename: el ? el.files[0].name : null,
        created_at: new Date(),
        message_identifier: uuid
      }),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }, () => {
      this.props.sendImg(this.props.currentCustomer, file_data ? file_data : data, csrfToken);
      this.scrollToBottom();
    });

    $('#divMessage').html(null);
  }

  scrollToBottom = () => {
    this.bottomRef.current.scrollIntoView();
  }

  handleScrollToTop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    if (el.scrollTop >= 0 && el.scrollTop <= 5 && this.props.currentCustomer === this.props.customer.id) {
      el.scrollTop = 10;
      this.handleLoadMore();
    }
  }

  openImage = (url) => {
    this.setState({
      imageUrl: url,
      isOpenImage: true
    });
  }

  componentWillReceiveProps(newProps){
    if (newProps.messages !== this.props.messages && newProps.messages.length > 0 &&
      this.props.currentCustomer === newProps.messages[0].customer_id) {
      const concatArray = newProps.messages.concat(this.state.messages);
      this.setState({
        new_message: false,
        // eslint-disable-next-line no-undef
        messages: _.uniqWith(concatArray, _.isEqual),
        load_more: false,
      })
    }

    if (newProps.selectedFastAnswer) {
      this.state.selectedFastAnswer = newProps.selectedFastAnswer;
      this.props.changeFastAnswer(null);
      this.removeSelectedProduct();
    }

    if (newProps.selectedProduct) {
      this.state.selectedProduct = newProps.selectedProduct;
      this.props.selectProduct(null);
      this.removeSelectedFastAnswer();
    }
  }

  componentDidMount() {
    let id = this.props.currentCustomer;
    currentCustomer = id;

    this.setState({ messages: [], page: 1, scrolable: true, selectedProduct: null, selectedFastAnswer: null }, () => {
      this.props.fetchMessages(id);
      this.scrollToBottom();
    });

    socket.on("message_facebook_chat", data => this.updateChat(data));

    this.setFocus();
  }

  componentDidUpdate() {
    let id = this.props.currentCustomer;
    if (this.state.new_message) {
      this.setState({
        new_message: false,
      })
    }

    if (currentCustomer !== id) {
      currentCustomer = id;
      this.scrollToBottom();
      this.setState({ messages: [], page: 1, scrolable: true, selectedProduct: null, selectedFastAnswer: null }, () => {
        this.props.fetchMessages(id);
      });
    }

    if (this.state.scrolable) {
      this.scrollToBottom();
    }
  }

  findMessageInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id === id
    ))
  )

  addArrivingMessage = (currentMessages, newMessage) => {
    // Find and replace element if it exists
    const index = currentMessages.findIndex((el) => (
      el.id === newMessage.id || (newMessage.message_identifier && el.message_identifier === newMessage.message_identifier)
    ));

    if (index === -1) {
      currentMessages = currentMessages.concat(newMessage);
    } else {
      currentMessages = currentMessages.map((message) => ((newMessage.id === message.id
        || (newMessage.message_identifier && message.message_identifier === newMessage.message_identifier))
        ? newMessage : message));
    }

    return currentMessages;
  }

  updateChat = (data) => {
    let facebookMessage = data.facebook_message.facebook_message;

    if (currentCustomer === facebookMessage.customer_id) {
      if (!this.state.new_message) {
        if (!facebookMessage.text && !facebookMessage.url) return;

        this.setState((prevState) => ({
          messages: this.addArrivingMessage(prevState.messages, facebookMessage),
          new_message: false
        }))
      }

      if (facebookMessage.sent_by_retailer === false) {
        this.props.setMessageAsRead(facebookMessage.id, csrfToken);
      }

      if (facebookMessage.sent_by_retailer === true && facebookMessage.date_read) {
        this.state.messages.filter(obj => obj.sent_by_retailer === true)
          .forEach(function(message) {
            if (!message.date_read && moment(message.created_at) <= moment(facebookMessage.created_at)) {
              message.date_read = facebookMessage.date_read
            }
        })
        this.setState({ messages: this.state.messages });
      }
    }
  }

  downloadFile = (e, file_url, filename) => {
    e.preventDefault();
    var link = document.createElement('a');
    link.href = file_url;
    link.download = filename;
    link.click();
  }

  fileType = (file_type) => {
    if (file_type == null) {
      return file_type;
    } else if (file_type.includes('image/') || file_type === 'image') {
      return 'image';
    } else if (['application/pdf', 'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel'].includes(file_type) ||
      file_type === 'file') {
        return 'file';
    } else if (file_type.includes('audio/') || file_type === 'audio') {
      return 'audio';
    } else if (file_type.includes('video/') || file_type === 'video') {
      return 'video';
    } else if (file_type.includes('location/') || file_type === 'location') {
      return 'location';
    }
  }

  toggleFastAnswers = () => {
    this.props.toggleFastAnswers();
  }

  toggleProducts = () => {
    this.props.toggleProducts();
  }

  removeSelectedProduct = () => {
    this.setState({selectedProduct: null});
  }

  removeSelectedFastAnswer = () => {
    this.setState({selectedFastAnswer: null});
  }

  divClasses = (message) => {
    var classes = message.sent_by_retailer === true ? 'message-by-retailer f-right' : 'message-by-customer';
    classes += ' main-message-container';
    if (message.sent_by_retailer === true && message.date_read)
      classes += ' read-message';
    if (['voice', 'audio'].includes(this.fileType(message.file_type))) classes += ' video-audio audio-background';
    if (this.fileType(message.file_type) === 'video') classes += ' video-audio no-background';
    if (this.fileType(message.file_type) === 'image') classes += ' no-background';
    return classes;
  }

  handleAgentAssignment = (e) => {
    var value = parseInt(e.target.value);
    var agent = this.props.agent_list.filter(agent => agent.id === value);

    var r = confirm("Estás seguro de asignar este chat a otro agente?");
    if (r === true) {
      var params = {
        agent: {
          retailer_user_id: agent[0] ? agent[0].id : null,
          chat_service: 'facebook'
        }
      };

      this.props.customerDetails.assigned_agent.id = value;
      this.props.changeCustomerAgent(this.props.currentCustomer, params, csrfToken);
    }
  }

  setNoRead = (e) => {
    e.preventDefault();
    this.props.setNoRead(this.props.currentCustomer, csrfToken, 'facebook');
  }

  onDrop = (files) => {
    if (this.state.loadedImages.length >= 5) {
      alert('Error: Máximo 5 imágenes permitidas');
      return;
    }

    var showError = false;
    for (var x in files) {
      if (this.validateImages(files[x])) {
        if (this.state.loadedImages.length >= 5) {
          alert('Error: Máximo 5 imágenes permitidas');
          return;
        }

        this.setState({ loadedImages: this.state.loadedImages.concat(files[x]) });
      } else {
        showError = true;
      }
    }

    if (showError || !files || files.length === 0) {
      alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 8MB');
    }
  }

  validateImages = (file) => {
    if (!['image/jpg', 'image/jpeg', 'image/png'].includes(file.type) || file.size > 8*1024*1024) {
      return false;
    }

    return true;
  }

  toggleLoadImages = () => {
    this.setState({
      showLoadImages: !this.state.showLoadImages,
      loadedImages: []
    });
  }

  removeImage = (index) => {
    this.state.loadedImages.splice(index, 1);
    this.setState({ loadedImages: this.state.loadedImages });
  }

  sendImages = () => {
    let insertedMessages = [];
    let uuid, url, type;
    const data = new FormData();

    this.state.loadedImages.map((image) => {
      uuid = uuidv4();
      data.append('file_data[]', image);
      data.append('message_identifiers[]', uuid);

      url = URL.createObjectURL(image);
      type = this.fileType(image.type);

      insertedMessages.push({
        url: url,
        sent_by_retailer: true,
        file_type: type,
        created_at: new Date(),
        message_identifier: uuid
      })
    });

    this.setState({
      messages: this.state.messages.concat(insertedMessages),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    });

    this.props.sendBulkFiles(this.props.currentCustomer, data, csrfToken);
    this.scrollToBottom();
    this.toggleLoadImages();
  }

  pasteImages = (e, fromSelector) => {
    e.preventDefault();

    if (e.clipboardData || e.originalEvent.clipboardData) {
      var clipboard = e.clipboardData || e.originalEvent.clipboardData;
      var pos = clipboard.types.indexOf('Files');

      if (pos !== -1) {
        if (clipboard.items) {
          var file = clipboard.items[pos].getAsFile();
        } else if (clipboard.files) {
          var file = clipboard.files[0];
        }

        if (file) {
          if (!this.validateImages(file)) {
            alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 8MB');
            return;
          }

          this.setState({
            loadedImages: this.state.loadedImages.concat(file),
            showLoadImages: true
          })
        } else {
          alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 8MB');
        }
      } else {
        if (!fromSelector) {
          var text = clipboard.getData('text/plain');
          document.execCommand('insertText', false, text);
        }
      }
    }
  }

  overwriteStyle = () => {
    return ENV['CURRENT_AGENT_ROLE'] === 'Supervisor' ? { height: '80vh'} : {}
  }

  canSendMessages = () => {
    return ENV['CURRENT_AGENT_ROLE'] !== 'Supervisor';
  }

  chatAlreadyAssigned = () => {
    return (
      this.props.currentCustomer !== 0 &&
      this.props.removedCustomer &&
      this.props.currentCustomer === this.props.removedCustomerId
    );
  }

  setFocus = (position) => {
    if (!this.canSendMessages()) {
      return true;
    }
    const node = document.getElementById("divMessage");
    let caret = 0;
    const input = $(node);
    const text = input.text();

    node.focus();

    if (position) {
      caret = position;
    } else {
      caret = text.length;
    }

    if (caret > 0) {
      const range = document.createRange();
      let dynamicCaret = caret;
      node.childNodes.forEach((textNode) => {
        if (dynamicCaret <= textNode.length) {
          range.setStart(textNode, dynamicCaret);
          range.setEnd(textNode, dynamicCaret);
          return;
        }
        dynamicCaret -= textNode.length;
      });

      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }

    this.caretPosition = caret;
  }

  objectPresence = () => ((this.state.selectedProduct && this.state.selectedProduct.attributes.image)
    || (this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url))

  sendLocation = (position) => {
    const uuid = uuidv4();
    let text = {
      message: `https://www.google.com/maps/place/${position.lat},${position.lng}`,
      type: 'location',
      message_identifier: uuid
    }

    this.setState({ messages: this.state.messages.concat(
      {
        url: text.message,
        sent_by_retailer: true,
        file_type: 'location',
        message_identifier: uuid
      }
    ), new_message: true, showMap: false}, () => {
      this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
      this.scrollToBottom();
    });
  }

  toggleMap = () => {
    this.setState({
      showMap: !this.state.showMap
    });
  }

  insertEmoji = (emoji) => {
    let input = $('#divMessage');
    let text = input.text();
    let first = text.substring(0, this.caretPosition);
    let second = text.substring(this.caretPosition);

    if (text.length == 0) this.caretPosition = 0;

    text = (first + emoji.native + second);
    input.html(text);

    this.setFocus(this.caretPosition + emoji.native.length);
  }

  getCaretPosition = () => {
    let sel;
    let range;
    const editableDiv = document.getElementById('divMessage');
    editableDiv.normalize();

    if (window.getSelection) {
      sel = window.getSelection();

      if (sel.rangeCount) {
        range = sel.getRangeAt(0);

        if (range.commonAncestorContainer.parentNode == editableDiv) {
          this.caretPosition = range.endOffset;
        }
      }
    } else if (document.selection && document.selection.createRange) {
      range = document.selection.createRange();

      if (range.parentElement() == editableDiv) {
        let tempEl = document.createElement("span");
        editableDiv.insertBefore(tempEl, editableDiv.firstChild);

        let tempRange = range.duplicate();
        tempRange.moveToElementText(tempEl);
        tempRange.setEndPoint("EndToEnd", range);

        this.caretPosition = tempRange.text.length;
      }
    }
  }

  toggleChatBot = (e) => {
    e.preventDefault();

    const params = {
      chat_service: 'facebook'
    }
    this.props.toggleChatBot(this.props.currentCustomer, params, csrfToken);
  }

  lastCustomerMessage = () => {
    let customerMessages = [];
    if (this.state.messages.length > 0) {
      customerMessages = this.state.messages.filter((message) => (message.sent_by_retailer === false));
    }
    return customerMessages[customerMessages.length - 1];
  };

  lastInteraction = () => {
    const latestCustomerMessage = this.lastCustomerMessage();
    return latestCustomerMessage && moment().local().diff(latestCustomerMessage.created_at, 'days') > 7;
  };

  render() {
    return (
      <div className="row bottom-xs">
        {this.props.onMobile && (
          <MobileTopChatBar
            backToChatList={this.props.backToChatList}
            customerDetails={this.props.customerDetails}
            editCustomerDetails={this.props.editCustomerDetails}
          />
        )}
        { this.props.currentCustomer !== 0 && (!this.props.removedCustomer || (this.props.removedCustomer && this.props.currentCustomer !== this.props.removedCustomerId)) &&
          (
            <TopChatBar
              activeChatBot={this.props.activeChatBot}
              agent_list={this.props.agent_list}
              customer={this.props.customer}
              customerDetails={this.props.customerDetails}
              handleAgentAssignment={this.handleAgentAssignment}
              newAgentAssignedId={this.props.newAgentAssignedId}
              onMobile={this.props.onMobile}
              setNoRead={this.setNoRead}
              toggleChatBot={this.toggleChatBot}
            />
          )}
        {this.state.isOpenImage && (
          <Lightbox
            mainSrc={this.state.imageUrl}
            onCloseRequest={() => this.setState({ isOpenImage: false })}
            imageLoadErrorMessage="Error al cargar la imagen"
          />
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)} style={this.overwriteStyle()}>
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
              <div className={ this.divClasses(message) }>
                <ChatMessage
                  message={message}
                  downloadFile={this.downloadFile}
                  fileType={this.fileType}
                  openImage={this.openImage}
                  />
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef}></div>
        </div>

        { this.chatAlreadyAssigned() ? (
            <AlreadyAssignedChatLabel/>
            )
            : (this.lastInteraction() ? (
              <p>Este canal de chat no ha tenido actividad del cliente los últimos 7 días, por lo tanto se encuentra cerrado.</p>
            )
            : (
            this.canSendMessages() &&
              <div className="col-xs-12 chat-input">
                <MessageForm
                  handleSubmitMessage={this.handleSubmitMessage}
                  handleSubmitImg={this.handleSubmitImg}
                  toggleFastAnswers={this.toggleFastAnswers}
                  selectedFastAnswer={this.state.selectedFastAnswer}
                  toggleProducts={this.toggleProducts}
                  selectedProduct={this.state.selectedProduct}
                  removeSelectedProduct={this.removeSelectedProduct}
                  onMobile={this.props.onMobile}
                  toggleLoadImages={this.toggleLoadImages}
                  pasteImages={this.pasteImages}
                  removeSelectedFastAnswer={this.removeSelectedFastAnswer}
                  objectPresence={this.objectPresence}
                  toggleMap={this.toggleMap}
                  getCaretPosition={this.getCaretPosition}
                  insertEmoji={this.insertEmoji}
                />
              </div>
          ))
        }

        <ImagesSelector
          showLoadImages={this.state.showLoadImages}
          loadedImages={this.state.loadedImages}
          toggleLoadImages={this.toggleLoadImages}
          onDrop={this.onDrop}
          removeImage={this.removeImage}
          sendImages={this.sendImages}
          onMobile={this.props.onMobile}
          pasteImages={this.pasteImages}
        />

        <GoogleMap
          showMap={this.state.showMap}
          toggleMap={this.toggleMap}
          onMobile={this.props.onMobile}
          zoomLevel={this.state.zoomLevel}
          sendLocation={this.sendLocation}
        />
      </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    messages: state.messages || [],
    message: state.message || [],
    total_pages: state.total_pages || 0,
    agents: state.agents || [],
    agent_list: state.agent_list || [],
    customer: state.customer
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id, page = 1) => {
      dispatch(fetchMessages(id, page));
    },
    sendMessage: (id, message, token) => {
      dispatch(sendMessage(id, message, token));
    },
    sendImg: (id, body, token) => {
      dispatch(sendImg(id, body, token));
    },
    setMessageAsRead: (id, token) => {
      dispatch(setMessageAsRead(id, token))
    },
    changeCustomerAgent: (id, body, token) => {
      dispatch(changeCustomerAgent(id, body, token));
    },
    setNoRead: (customer_id, token, chatType) => {
      dispatch(setNoRead(customer_id, token, chatType));
    },
    sendBulkFiles: (id, body, token) => {
      dispatch(sendBulkFiles(id, body, token));
    },
    toggleChatBot: (customerId, params, token) => {
      dispatch(toggleChatBot(customerId, params, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
