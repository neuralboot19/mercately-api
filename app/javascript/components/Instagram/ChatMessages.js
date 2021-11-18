import React, { Component } from "react";
import moment from 'moment';
import Lightbox from 'react-image-lightbox';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { v4 as uuidv4 } from 'uuid';
import {
  fetchMessages,
  sendMessage,
  sendImg,
  setMessageAsRead,
  sendBulkFiles,
  addNote as addNoteAction
} from "../../actions/actions";

import {
  changeCustomerAgent,
  setNoRead,
  toggleChatBot,
  setLastFBMessages
} from "../../actions/whatsapp_karix";

import MessageForm from './MessageForm';
import ChatMessage from './ChatMessage';
import ImagesSelector from "../shared/ImagesSelector";
import GoogleMap from "../shared/Map";
import TopChatBar from '../shared/TopChatBar';
import AlreadyAssignedChatLabel from '../shared/AlreadyAssignedChatLabel';
import MobileTopChatBar from '../shared/MobileTopChatBar';
import NoteModal from '../shared/NoteModal';
import DealModal from '../shared/DealModal';

import 'react-image-lightbox/style.css';
import fileUtils from '../../util/fileUtils';
import { DEFAULT_IMAGE_SIZE_TRANSFER, MAX_IMAGE_SIZE_TRANSFER } from '../../constants/chatFileSizes';
import stringUtils from '../../util/stringUtils';
import { fetchFunnelSteps, fetchCustomerDeals } from '../../actions/funnels';
import { fetchCurrentRetailerUser } from "../../actions/actions";

let currentCustomer = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content;

class ChatMessages extends Component {
  constructor(props) {
    super(props);
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
      imageUrl: null,
      showInputMenu: false,
      isNoteModalOpen: false,
      showOptions: !props.onMobile,
      inputFilled: false,
      isDealModalOpen: false
    };
    this.bottomRef = React.createRef();
    this.noteTextRef = React.createRef();
    this.caretPosition = 0;
  }

  submitNote = () => {
    const message = this.noteTextRef.current.value;
    if (message.trim() === '') return;

    const uuid = uuidv4();
    const text = { message, message_identifier: uuid, note: true };
    this.setState(
      {
        messages: this.state.messages.concat({
          note: true,
          text: message,
          sent_by_retailer: true,
          created_at: new Date(),
          message_identifier: uuid
        }),
        new_message: true
      }, () => {
        this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
        this.props.addNote({
          id: uuid,
          message,
          // eslint-disable-next-line no-undef
          retailer_user: ENV.CURRENT_AGENT_NAME || ENV.CURRENT_AGENT_EMAIL,
          created_at: new Date()
        });
        this.scrollToBottom();
      }
    );
    this.cancelNote();
  }

  cancelNote = () => {
    this.toggleNoteModal();
    this.noteTextRef.current.clearValue();
  }

  toggleNoteModal = () => {
    this.setState((prevState) => ({
      isNoteModalOpen: !prevState.isNoteModalOpen
    }));
  }

  handleLoadMore = () => {
    const id = this.props.currentCustomer;
    if (this.props.total_pages > this.state.page && !this.props.loadingMoreMessages) {
      this.setState({ page: this.state.page += 1, load_more: true, scrolable: false }, () => {
        this.props.fetchMessages(id, this.state.page);
      });
    }
  }

  handleSubmitMessage = (e, message) => {
    e.preventDefault();
    const uuid = uuidv4();
    let text = { message: message, message_identifier: uuid };
    const isText = message && message.trim() !== '';
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
        url,
        sent_by_retailer: true,
        file_type: type,
        filename: el ? el.files[0].name : null,
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
    const el = e.target;
    if (el.scrollTop >= 0 && el.scrollTop <= 5) {
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
      if (this.props.customerDetails.last_fb_messages) {
        this.props.setLastFBMessages(this.props.customerDetails);
      } else {
        this.props.fetchMessages(id);
      }
      this.scrollToBottom();
    });

    this.props.fetchFunnelSteps();
    this.props.fetchCurrentRetailerUser();

    socket.on('message_instagram_chat', (data) => this.updateChat(data));

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
        if (this.props.customerDetails.last_fb_messages) {
          this.props.setLastFBMessages(this.props.customerDetails);
        } else {
          this.props.fetchMessages(id);
        }
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
    const facebookMessage = data.facebook_message.instagram_message;

    if (currentCustomer === facebookMessage.customer_id) {
      if (!this.state.new_message) {
        if (!facebookMessage.text && !facebookMessage.url) return;

        this.setState((prevState) => ({
          messages: this.addArrivingMessage(prevState.messages, facebookMessage),
          new_message: false
        }));
      }

      if (facebookMessage.sent_by_retailer === false) {
        this.props.setMessageAsRead(facebookMessage.id, csrfToken);
      }

      if (facebookMessage.sent_by_retailer === true && facebookMessage.date_read) {
        this.state.messages.filter((obj) => obj.sent_by_retailer === true && obj.note === false)
          .forEach((message) => {
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
    let link = document.createElement('a');
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
    this.handleShowInputMenu();
  }

  removeSelectedProduct = () => {
    this.setState({selectedProduct: null});
  }

  removeSelectedFastAnswer = () => {
    this.setState({selectedFastAnswer: null});
  }

  divClasses = (message) => {
    let classes = message.sent_by_retailer === true ? 'message-by-retailer f-right' : 'message-by-customer';
    classes += ' main-message-container';
    if (message.note === true) classes += ' note-message';
    if (['voice', 'audio'].includes(this.fileType(message.file_type))) classes += ' video-audio audio-background';
    if (this.fileType(message.file_type) === 'video') classes += ' video-audio no-background';
    if (['image', 'video', 'sticker'].includes(this.fileType(message.file_type))) classes += ' no-background media-container';
    return classes;
  }

  handleAgentAssignment = (e) => {
    let value = parseInt(e.value);
    let agent = this.props.agent_list.filter(agent => agent.id === value);

    let r = confirm("Estás seguro de asignar este chat a otro agente?");
    if (r === true) {
      let params = {
        agent: {
          retailer_user_id: agent[0] ? agent[0].id : null,
          chat_service: 'instagram'
        }
      };

      this.props.customerDetails.assigned_agent.id = value;
      this.props.changeCustomerAgent(this.props.currentCustomer, params, csrfToken);
    }
  }

  setNoRead = (e) => {
    e.preventDefault();
    this.props.setNoRead(this.props.currentCustomer, csrfToken, 'instagram');
  }

  onDrop = (files) => {
    if (this.state.loadedImages.length >= 5) {
      alert('Error: Máximo 5 imágenes permitidas');
      return;
    }

    let showError = false;
    for (let x in files) {
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
      ENV.SEND_MAX_SIZE_FILES ? this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER) : this.displayErrorAlert(DEFAULT_IMAGE_SIZE_TRANSFER);
    }
  }

  displayErrorAlert(size) {
    let fileSize = fileUtils.sizeFileInMB(size);

    alert(`Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo ${fileSize}MB`);
  }

  validateImages = (file) => {
    if (!['image/jpg', 'image/jpeg', 'image/png'].includes(file.type)) {
      return false;
    }

    if (ENV.SEND_MAX_SIZE_FILES) {
      return fileUtils.isMaxImageSize(file);
    }
    return fileUtils.isDefaultImageSize(file);
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
      let clipboard = e.clipboardData || e.originalEvent.clipboardData;
      let pos = clipboard.types.indexOf('Files');

      if (pos !== -1) {
        let file;

        if (clipboard.items) {
          file = clipboard.items[pos].getAsFile();
        } else if (clipboard.files) {
          file = clipboard.files[0];
        }

        if (file) {
          if (!this.validateImages(file)) {
            ENV.SEND_MAX_SIZE_FILES ? this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER) : this.displayErrorAlert(DEFAULT_IMAGE_SIZE_TRANSFER);
            return;
          }

          this.setState({
            loadedImages: this.state.loadedImages.concat(file),
            showLoadImages: true
          })
        } else {
          ENV.SEND_MAX_SIZE_FILES ? this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER) : this.displayErrorAlert(DEFAULT_IMAGE_SIZE_TRANSFER);
        }
      } else if (!fromSelector) {
        const text = clipboard.getData('text/plain');
        e.target.innerText = stringUtils.addStr(e.target.innerText, this.caretPosition, text);
        this.setFocus(this.caretPosition + text.length);
      }
    }

    this.maximizeInputText();
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
    this.handleShowInputMenu();
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
    this.maximizeInputText();
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

    this.maximizeInputText();
  }

  toggleChatBot = (e) => {
    e.preventDefault();

    const params = {
      chat_service: 'instagram'
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

  handleShowInputMenu = () => {
    this.setState((prevState) => ({
      showInputMenu: !prevState.showInputMenu
    }));
  }

  toggleOptions = () => this.setState(({ showOptions }) => ({ showOptions: !showOptions }));

  maximizeInputText = () => {
    const input = $('#divMessage');
    const text = input.text();
    let filled;

    if (text.length == 0) {
      filled = false;
    } else {
      filled = true;
    };

    if (this.state.inputFilled !== filled) this.setState({ inputFilled: filled });
  }

  toggleDealModal = () => {
    this.setState((prevState) => ({
      isDealModalOpen: !prevState.isDealModalOpen
    }))
  }

  getCustomerDeals = () => {
    this.props.fetchCustomerDeals(this.props.currentCustomer);
  }

  render() {
    const chatBoxClass = this.state.showOptions && this.props.onMobile
      ? 'chat__box chat__box-without-options'
      : `chat__box ${ this.state.inputFilled && 'maximize' }`;

    return (
      <div className="chat-messages-holder bottom-xs">
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
              agentsList={this.props.agent_list}
              customer={this.props.customer}
              customerDetails={this.props.customerDetails}
              handleAgentAssignment={this.handleAgentAssignment}
              newAgentAssignedId={this.props.newAgentAssignedId}
              onMobile={this.props.onMobile}
              showOptions={this.state.showOptions}
              setNoRead={this.setNoRead}
              toggleChatBot={this.toggleChatBot}
              toggleOptions={this.toggleOptions}
              chatType='instagram'
            />
          )}
        {this.state.isOpenImage && (
          <Lightbox
            mainSrc={this.state.imageUrl}
            onCloseRequest={() => this.setState({ isOpenImage: false })}
            imageLoadErrorMessage="Error al cargar la imagen"
          />
        )}
        <div
          className={`col-xs-12 mt-8 px-24 border-top-light ${chatBoxClass}`}
          onScroll={(e) => this.handleScrollToTop(e)}
          style={this.overwriteStyle()}
        >
          {this.state.messages.map((message) => (
            <div key={message.id} className="message text-gray-dark">
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
              <p className="p-24 text-gray-dark">
                Este canal de chat no ha tenido actividad del cliente los últimos 7 días,
                por lo tanto se encuentra cerrado.
                Si lo desea puede <a href="#" onClick={() => this.toggleNoteModal()}>añadir una nota en el chat.</a>
              </p>
            )
            : (
              this.canSendMessages() && (
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
                  showInputMenu={this.state.showInputMenu}
                  handleShowInputMenu={this.handleShowInputMenu}
                  openNoteModal={this.toggleNoteModal}
                  maximizeInputText={this.maximizeInputText}
                  inputFilled={this.state.inputFilled}
                  openDealModal={this.toggleDealModal}
                />
              )
            )
          )
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

        <NoteModal
          ref={this.noteTextRef}
          onMobile={this.props.onMobile}
          cancelNote={this.cancelNote}
          submitNote={this.submitNote}
          isNoteModalOpen={this.state.isNoteModalOpen}
          toggleNoteModal={this.toggleNoteModal}
        />

        { this.state.isDealModalOpen ?
          <DealModal
            customer={this.props.customer}
            funnelSteps={this.props.funnelSteps}
            isDealModalOpen={this.state.isDealModalOpen}
            toggleDealModal={this.toggleDealModal}
            dealSelected={null}
            agents={this.props.agents}
            getCustomerDeals={this.getCustomerDeals}
          />
          :
          false
        }
      </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    messages: state.messages || [],
    message: state.message || [],
    total_pages: state.total_fb_pages || 0,
    agents: state.agents || [],
    agent_list: state.agent_list || [],
    customer: state.customer,
    loadingMoreMessages: state.loadingMoreMessages || false,
    funnelSteps: state.funnelSteps || {},
    fetchingFunnels: state.fetching_funnels || false
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id, page = 1) => {
      dispatch(fetchMessages(id, page, 'instagram'));
    },
    sendMessage: (id, message, token) => {
      dispatch(sendMessage(id, message, token, 'instagram'));
    },
    sendImg: (id, body, token) => {
      dispatch(sendImg(id, body, token, 'instagram'));
    },
    setMessageAsRead: (id, token) => {
      dispatch(setMessageAsRead(id, token, 'instagram'))
    },
    changeCustomerAgent: (id, body, token) => {
      dispatch(changeCustomerAgent(id, body, token));
    },
    setNoRead: (customer_id, token, chatType) => {
      dispatch(setNoRead(customer_id, token, chatType));
    },
    sendBulkFiles: (id, body, token) => {
      dispatch(sendBulkFiles(id, body, token, 'instagram'));
    },
    toggleChatBot: (customerId, params, token) => {
      dispatch(toggleChatBot(customerId, params, token));
    },
    setLastFBMessages: (customerDetails) => {
      dispatch(setLastFBMessages(customerDetails));
    },
    addNote: (body) => {
      dispatch(addNoteAction(body));
    },
    fetchFunnelSteps: () => {
      dispatch(fetchFunnelSteps());
    },
    fetchCustomerDeals: (customerId) => {
      dispatch(fetchCustomerDeals(customerId))
    },
    fetchCurrentRetailerUser: () => {
      dispatch(fetchCurrentRetailerUser());
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
