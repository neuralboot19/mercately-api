import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import moment from 'moment';
import Lightbox from 'react-image-lightbox';
import { v4 as uuidv4 } from 'uuid';
import {
  changeCustomerAgent,
  fetchWhatsAppMessages,
  fetchWhatsAppTemplates,
  sendWhatsAppBulkFiles,
  sendWhatsAppImg,
  sendWhatsAppMessage,
  setNoRead,
  setWhatsAppMessageAsRead,
  toggleChatBot,
  createReminder,
  setLastMessages,
  sendWhatsAppMultipleAnswers,
  toggleBlockUser
} from '../../actions/whatsapp_karix';
import {
  addNote as addNoteAction
} from "../../actions/actions";
import ImagesSelector from '../shared/ImagesSelector';
import GoogleMap from '../shared/Map';
import Message from './Message';
import 'emoji-mart/css/emoji-mart.css';
import TopChatBar from '../shared/TopChatBar';
import ClosedChannel from './ClosedChannel';
import MessageForm from './MessageForm';
import AlreadyAssignedChatLabel from '../shared/AlreadyAssignedChatLabel';
import TemplateSelectionModal from './TemplateSelectionModal';
import MobileTopChatBar from '../shared/MobileTopChatBar';
import ErrorSendingMessageLabel from './ErrorSendingMessageLabel';
import ReminderConfigModal from './ReminderConfigModal';
import NoteModal from '../shared/NoteModal';
import DealModal from '../shared/DealModal';
import BlockedUserMessage from './BlockedUserMessage';
import 'react-image-lightbox/style.css';

import fileUtils from '../../util/fileUtils';
import {
  DEFAULT_FILE_SIZE_TRANSFER,
  MAX_FILE_SIZE_TRANSFER,
  MAX_IMAGE_SIZE_TRANSFER_WS,
  MAX_VIDEO_SIZE_TRANSFER_WS
} from '../../constants/chatFileSizes';
import stringUtils from '../../util/stringUtils';
import { fetchFunnelSteps, fetchCustomerDeals } from '../../actions/funnels';
import { fetchCurrentRetailerUser } from '../../actions/actions';

let currentCustomer = 0;
let totalPages = 0;
let comesFromSelection = false;
let justMounted = false;
let templateParams = {};
let gupshupTemplateId;
let templateSelectedId;
const csrfToken = document.querySelector('[name=csrf-token]').content;

class ChatMessages extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: [],
      new_message: false,
      page: 1,
      scrolable: false,
      load_more: false,
      can_write: true,
      isModalOpen: false,
      isTemplateSelected: false,
      templateSelected: '',
      templateEdited: false,
      auxTemplateSelected: [],
      agents: [],
      updated: true,
      selectedProduct: null,
      showLoadImages: false,
      loadedImages: [],
      selectedFastAnswer: null,
      showMap: false,
      zoomLevel: 17,
      recordingAudio: false,
      totalSeconds: 0,
      audioSeconds: '00',
      audioMinutes: '00',
      showEmojiPicker: false,
      templateType: '',
      acceptedFiles: '',
      isReminderConfigModalOpen: false,
      isNoteModalOpen: false,
      isDealModalOpen: false,
      isOpenImage: false,
      imageUrl: null,
      showInputMenu: false,
      showOptions: !props.onMobile,
      inputFilled: false
    };
    this.bottomRef = React.createRef();
    this.noteTextRef = React.createRef();
    this.opted_in = false;
    this.cancelledAudio = false;
    this.caretPosition = 0;
  }

  handleLoadMore = () => {
    const id = this.props.currentCustomer;
    if (totalPages > this.state.page && !this.props.loadingMoreMessages) {
      this.setState((prevState) => (
        { page: prevState.page + 1, load_more: true, scrolable: false }
      ), () => {
        this.props.fetchWhatsAppMessages(id, this.state.page);
      });
    }
  }

  componentDidMount() {
    const id = this.props.currentCustomer;
    this.opted_in = this.props.customerDetails.whatsapp_opt_in;
    currentCustomer = id;

    this.setState({
      messages: [],
      page: 1,
      scrolable: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }, () => {
      justMounted = true;
      if (this.props.customerDetails.last_messages) {
        this.props.setLastMessages(this.props.customerDetails);
      } else {
        this.props.fetchWhatsAppMessages(id);
      }
    });

    this.props.fetchWhatsAppTemplates();
    this.props.fetchFunnelSteps();
    this.props.fetchCurrentRetailerUser();
    // eslint-disable-next-line no-undef
    socket.on("message_chat", (data) => this.updateChat(data));

    this.setFocus();
  }

  addArrivingMessage = (currentMessages, newMessage) => {
    // Remove messages with error, only keep those with error code 1002 (Number Does Not Exists On WhatsApp)
    let newMessagesArray = currentMessages.filter((message) => !message.error_code || message.error_code === 1002);
    // Then find and replace element if it exists
    const index = currentMessages.findIndex((el) => (
      el.id === newMessage.id || (newMessage.message_identifier && el.message_identifier === newMessage.message_identifier)
    ));

    if (index === -1) {
      newMessagesArray = newMessagesArray.concat(newMessage);
    } else {
      newMessagesArray = newMessagesArray.map((message) => ((newMessage.id === message.id
        || (newMessage.message_identifier && message.message_identifier === newMessage.message_identifier)) ? newMessage : message));
    }

    return newMessagesArray;
  }

  updateChat = (data) => {
    const newMessage = data.karix_whatsapp_message.karix_whatsapp_message;
    if (currentCustomer === newMessage.customer_id) {
      if (!this.state.new_message) {
        this.setState((prevState) => ({
          messages: this.addArrivingMessage(prevState.messages, newMessage),
          new_message: false,
          updated: false,
          scrolable: false
        }), () => this.setState({ updated: true, scrolable: false }));
      }
      if (newMessage.direction === 'inbound') {
        this.props.setWhatsAppMessageAsRead(currentCustomer, { message_id: newMessage.id }, csrfToken);
        this.state.can_write = true;
      }
    }
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps(newProps) {
    if (newProps.messages !== this.props.messages
        && newProps.messages.length > 0
        && this.props.currentCustomer === newProps.messages[0].customer_id) {
      const rDate = moment(newProps.recentInboundMessageDate).local();
      this.setState((prevState) => ({
        new_message: false,
        // eslint-disable-next-line no-undef
        messages: _.uniqWith(newProps.messages.concat(prevState.messages), _.isEqual),
        load_more: false,
        can_write: moment().local().diff(rDate, 'hours') < 24
      }), () => {
        this.opted_in = false;
        if (this.props.customer !== undefined) {
          this.opted_in = this.props.customer.whatsapp_opt_in || false;
        }
      });
    }

    if (newProps.selectedFastAnswer) {
      this.state.selectedFastAnswer = newProps.selectedFastAnswer;
      $('#divMessage').html(this.state.selectedFastAnswer.attributes.answer);
      this.props.changeFastAnswer(null);
      this.removeSelectedProduct();
      this.maximizeInputText();
    }

    if (newProps.selectedProduct) {
      this.state.selectedProduct = newProps.selectedProduct;
      let productString = '';
      productString += (`${this.state.selectedProduct.attributes.title}\n`);
      productString += (`Precio ${this.state.selectedProduct.attributes.currency}${this.state.selectedProduct.attributes.price}\n`);
      productString += (`${this.state.selectedProduct.attributes.description}\n`);
      productString += (this.state.selectedProduct.attributes.url ? this.state.selectedProduct.attributes.url : '');
      $('#divMessage').html(productString);
      this.props.selectProduct(null);
      this.removeSelectedFastAnswer();
      this.maximizeInputText();
    }
  }

  componentDidUpdate() {
    const id = this.props.currentCustomer;
    const rDate = moment(this.props.recentInboundMessageDate).local();
    if (this.state.new_message) {
      this.setState({
        can_write: moment().local().diff(rDate, 'hours') < 24,
        new_message: false
      });
    }

    if (currentCustomer !== id) {
      currentCustomer = id;
      totalPages = 0;
      comesFromSelection = true;
      this.opted_in = this.props.customer.whatsapp_opt_in;
      this.setState({
        messages: [],
        page: 1,
        scrolable: true,
        selectedProduct: null,
        selectedFastAnswer: null
      }, () => {
        if (this.props.customerDetails.last_messages) {
          this.props.setLastMessages(this.props.customerDetails);
        } else {
          this.props.fetchWhatsAppMessages(id);
        }
      });

      this.props.fetchWhatsAppTemplates();
    } else if ((comesFromSelection || justMounted) && this.state.messages.length) {
      this.scrollToBottom();
      comesFromSelection = false;
      justMounted = false;
    }
  }

  scrollToBottom = () => {
    this.bottomRef.current.scrollIntoView();
  }

  onKeyPress = (e) => {
    if (e.which === 13 && e.shiftKey && e.target.innerText.trim() === "") e.preventDefault();
    if (e.which === 13 && !e.shiftKey) {
      e.preventDefault();
      this.handleSubmit(e);
    }
  }

  handleSubmit = (e) => {
    e.persist();
    this.setState({
      showEmojiPicker: false
    });

    if (this.hasAdditionalAnswers()) {
      this.sendMultipleAnswers();
      return;
    }

    if (this.objectPresence()) {
      this.handleSubmitImg();
      return;
    }

    const input = $('#divMessage');
    const text = input.text();
    if (text.trim() === '') return;

    const txt = this.getText();
    const rDate = moment(this.props.recentInboundMessageDate).local();
    this.setState({
      can_write: moment().local().diff(rDate, 'hours') < 24
    }, () => {
      if (this.state.can_write) {
        this.setState({ selectedProduct: null, selectedFastAnswer: null }, () => {
          this.handleSubmitWhatsAppMessage(e, txt, false);
          input.html(null);
          this.maximizeInputText();
        });
      }
    });

    this.setFocus();
  }

  sendMultipleAnswers = () => {
    const answer = this.state.selectedFastAnswer.attributes;
    const insertedMessages = [];
    const text = this.getText();
    const data = new FormData();
    let uuid = uuidv4();
    let type = 'text';
    let url = stringUtils.formatSentUrl(answer.image_url);
    let filename;

    data.append('template', false);
    data.append('message_identifier', uuid);
    data.append('template_id', answer.id);

    if (answer.file_type === 'file') {
      type = 'document';
      filename = answer.file_name;
      data.append('file_name', filename);
      data.append('content_type', 'application/pdf');
    } else if (answer.file_type === 'image') {
      type = 'image';
      data.append('content_type', 'image');
    }

    data.append('type', type);

    if (url) {
      data.append('url', url);
      data.append('caption', text);
    } else {
      data.append('message', text);
    }

    insertedMessages.push({
      content_type: type === 'text' ? 'text' : 'media',
      content_media_type: type,
      content_media_url: url,
      direction: 'outbound',
      content_text: type === 'text' ? text : null,
      content_media_caption: type !== 'text' ? text : null,
      status: 'enqueued',
      filename: filename,
      created_time: new Date(),
      message_identifier: uuid
    });

    answer.additional_fast_answers.data.forEach((afa) => {
      uuid = uuidv4();
      data.append('message_identifiers[]', uuid);
      type = 'text';
      url = afa.attributes.file_url;

      if (afa.attributes.file_type === 'file') {
        type = 'document';
      } else if (afa.attributes.file_type === 'image') {
        type = 'image';
      }

      filename = type === 'document' ? afa.attributes.file_name : null;

      insertedMessages.push({
        content_type: type === 'text' ? 'text' : 'media',
        content_media_type: type,
        content_media_url: url,
        direction: 'outbound',
        content_text: type === 'text' ? afa.attributes.answer : null,
        content_media_caption: type !== 'text' ? afa.attributes.answer : null,
        status: 'enqueued',
        filename: filename,
        created_time: new Date(),
        message_identifier: uuid
      });
    });

    this.setState((prevState) => ({
      messages: prevState.messages.concat(insertedMessages),
      new_message: true,
      selectedFastAnswer: null
    }), () => {
      this.props.sendWhatsAppMultipleAnswers(this.props.currentCustomer, data, csrfToken);
      $('#divMessage').html(null);
      this.maximizeInputText();
      this.scrollToBottom();
    });

    this.setFocus();
  }

  hasAdditionalAnswers = () => {
    return this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.additional_fast_answers.data.length > 0;
  }

  handleSubmitWhatsAppMessage = (e, message, isTemplate) => {
    if (e) {
      e.preventDefault();
    }

    const uuid = uuidv4();
    const text = {
      message, customer_id: this.props.currentCustomer, template: isTemplate, type: 'text', message_identifier: uuid
    };

    if (isTemplate) {
      text.gupshup_template_id = gupshupTemplateId;

      const params = Object.values(templateParams);
      text.template_params = [];

      params.forEach((value) => text.template_params.push(value));
    }

    this.setState((prevState) => ({
      messages: prevState.messages.concat({
        content_type: 'text',
        content_text: message,
        direction: 'outbound',
        status: 'enqueued',
        created_time: new Date(),
        message_identifier: uuid
      }),
      new_message: true
    }), () => {
      this.props.sendWhatsAppMessage(text, csrfToken);
      this.scrollToBottom();
    });
  }

  submitNote = () => {
    const message = this.noteTextRef.current.value;
    if (message.trim() === '') return;

    const uuid = uuidv4();
    const text = {
      message,
      customer_id: this.props.currentCustomer,
      note: true,
      type: 'text',
      message_identifier: uuid
    };
    this.setState((prevState) => ({
      messages: prevState.messages.concat({
        note: true,
        content_type: 'text',
        content_text: message,
        direction: 'outbound',
        status: 'enqueued',
        created_time: new Date(),
        message_identifier: uuid
      }),
      new_message: true
    }), () => {
      this.props.sendWhatsAppMessage(text, csrfToken);
      this.props.addNote({
        id: uuid,
        message,
        // eslint-disable-next-line no-undef
        retailer_user: ENV.CURRENT_AGENT_NAME || ENV.CURRENT_AGENT_EMAIL,
        created_at: new Date()
      });
      this.scrollToBottom();
      this.cancelNote();
    });
  }

  removeFromMessagesByTextContent = (text, id) => {
    const { messages } = this.state;
    const index = messages.findIndex((el) => (
      el.content_text === text && el.id === id)
      || (el.content_text === text && !el.id
      ));

    if (index !== -1) {
      messages.splice(index, 1);
    }

    return messages;
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

  onDrop = (files) => {
    if (this.state.loadedImages.length >= 5) {
      alert('Error: M??ximo 5 im??genes permitidas');
      return;
    }

    let showError = false;

    Object.values(files).forEach((file) => {
      if (this.validateImages(file)) {
        if (this.state.loadedImages.length >= 5) {
          alert('Error: M??ximo 5 im??genes permitidas');
          return;
        }
        this.setState((prevState) => ({ loadedImages: prevState.loadedImages.concat(file) }));
      } else {
        showError = true;
      }
    });

    if (showError || !files || files.length === 0) {
      this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER_WS);
    }
  }

  displayErrorAlert(size) {
    let fileSize = fileUtils.sizeFileInMB(size);

    alert(`Error: Los archivos deben ser im??genes JPG/JPEG o PNG, de m??ximo ${fileSize}MB`);
  }

  validateImages = (file) => {
    if (!['image/jpg', 'image/jpeg', 'image/png'].includes(file.type)) {
      return false;
    }

    return fileUtils.isValidImageSizeForWs(file);
  }

  sendImages = () => {
    const insertedMessages = [];
    let uuid;
    const data = new FormData();
    data.append('template', false);
    data.append('type', 'image');
    this.state.loadedImages.forEach((image) => {
      uuid = uuidv4();
      data.append('file_data[]', image);
      data.append('message_identifiers[]', uuid);

      const url = URL.createObjectURL(image);
      const type = this.fileType(image.type);
      const caption = type === 'document' ? image.name : null;

      insertedMessages.push({
        content_type: 'media',
        content_media_type: type,
        content_media_url: url,
        direction: 'outbound',
        content_media_caption: caption,
        created_time: new Date(),
        message_identifier: uuid
      });
    });

    this.setState((prevState) => ({
      messages: prevState.messages.concat(insertedMessages),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }));

    this.props.sendWhatsAppBulkFiles(this.props.currentCustomer, data, csrfToken);
    this.scrollToBottom();
    this.toggleLoadImages();
  }

  handleSubmitImg = (el, fileData) => {
    let url;
    let type;
    let caption;
    let filename;
    const uuid = uuidv4();
    const input = $('#divMessage');
    const data = new FormData();

    if (this.state.selectedProduct || this.state.selectedFastAnswer) {
      url = this.state.selectedProduct
        ? this.state.selectedProduct.attributes.image
        : this.state.selectedFastAnswer.attributes.image_url;
      type = this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.file_type === 'file'
        ? 'application/pdf'
        : 'image';
      caption = this.getText();
      filename = type === 'application/pdf' && this.state.selectedFastAnswer ? this.state.selectedFastAnswer.attributes.file_name : null;

      if (type !== 'image' && this.state.selectedFastAnswer) data.append('file_name', this.state.selectedFastAnswer.attributes.file_name);
      data.append('template', false);
      data.append('url', stringUtils.formatSentUrl(url));
      data.append('content_type', type);
      data.append('type', 'file');
      data.append('caption', caption);
      data.append('message_identifier', uuid);
      if (type === 'application/pdf') type = 'document';
    } else if (fileData && fileData.get('template') === 'true') {
      fileData.append('message_identifier', uuid);
      const auxFile = fileData.get('file_data');

      url = URL.createObjectURL(auxFile);
      type = this.fileType(auxFile.type);
      filename = type === 'document' ? auxFile.name : null;
      caption = fileData.get('caption');

      fileData.append('gupshup_template_id', gupshupTemplateId);

      const insertedParams = Object.values(templateParams);
      insertedParams.forEach((value) => fileData.append('template_params[]', value));
    } else {
      fileData.append('message_identifier', uuid);
      url = URL.createObjectURL(el.files[0]);
      type = this.fileType(el.files[0].type);
      filename = type === 'document' ? el.files[0].name : null;
      caption = null;
    }

    this.setState((prevState) => ({
      messages: prevState.messages.concat(
        {
          content_type: 'media',
          content_media_type: type,
          content_media_url: url,
          direction: 'outbound',
          content_media_caption: caption,
          filename,
          created_time: new Date(),
          message_identifier: uuid
        }
      ),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }), () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, fileData || data, csrfToken);
      input.html(null);
      this.maximizeInputText();
      this.scrollToBottom();
    });
  }

  handleFileSubmit = (e) => {
    const el = e.target;
    const file = el.files[0];

    if (
      !['application/pdf', 'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel']
        .includes(file.type)) {
      alert('Error: El archivo debe ser de tipo PDF, Excel o Word');
      return;
    }

    // Max DYNAMIC Mb allowed
    let isValidSizeFile = fileUtils.isDefaultFileSize(file);

    if (ENV.SEND_MAX_SIZE_FILES) {
      isValidSizeFile = fileUtils.isMaxFileSize(file);
    }

    if (!isValidSizeFile) {
      let sizeFile = fileUtils.sizeFileInMB(DEFAULT_FILE_SIZE_TRANSFER);

      if (ENV.SEND_MAX_SIZE_FILES) {
        sizeFile = fileUtils.sizeFileInMB(MAX_FILE_SIZE_TRANSFER);
      }

      alert(`Error: Maximo permitido ${sizeFile}MB`);
      return;
    }

    const data = new FormData();
    data.append('file_data', file);
    data.append('template', false);
    this.handleSubmitImg(el, data);
    $('#attach-file').val('');
  }

  fileType = (type) => {
    if (type == null) {
      return type;
    } if (type.includes('image/') || type === 'image') {
      return 'image';
    } if (['application/pdf', 'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel'].includes(type)
      || type === 'document') {
      return 'document';
    } if (type.includes('audio/') || ['audio', 'voice'].includes(type)) {
      return 'audio';
    } if (type.includes('video/') || type === 'video') {
      return 'video';
    } if (type === 'sticker') {
      return 'sticker';
    }
    return null;
  }

  openImage = (url) => {
    this.setState({
      imageUrl: url,
      isOpenImage: true
    });
  }

  openModal = () => {
    // eslint-disable-next-line no-undef
    if (this.props.customer.whatsapp_opt_in || ENV.INTEGRATION === '0' || this.opted_in) {
      this.toggleModal();
    } else if (this.opted_in === false) {
      this.verifyOptIn('templates');
    }
  }

  toggleModal = () => {
    this.setState((prevState) => ({
      isModalOpen: !prevState.isModalOpen
    }));
  }

  selectTemplate = (template) => {
    gupshupTemplateId = template.gupshup_template_id;
    templateSelectedId = template.id;

    this.setState({
      isTemplateSelected: true,
      templateSelected: template.text,
      auxTemplateSelected: template.text.split(''),
      templateType: template.template_type
    }, () => {
      this.acceptedFiles();
    });
  }

  changeTemplateSelected = (e, id) => {
    this.state.templateSelected.split('').forEach((key, index) => {
      if (key === '*') {
        if (index === id && e.target.value && e.target.value !== '') {
          this.state.auxTemplateSelected[index] = e.target.value;
          templateParams[index] = e.target.value;
        } else if (index === id && (!e.target.value || e.target.value === '')) {
          this.state.auxTemplateSelected[index] = '*';
          templateParams[index] = '*';
        }
      }
    });

    this.setState({
      templateEdited: true
    });
  }

  getTextInput = () => {
    const newArray = this.state.templateSelected.split('');

    return newArray.map((key, index) => {
      if (key === '*') {
        if (index === 0 || newArray[index - 1] !== '\\') {
          return <input value="" onChange={(e) => this.changeTemplateSelected(e, index)} />;
        }
        return key;
      } if (key === '\\') {
        if (index === (newArray.length - 1) || newArray[index + 1] !== '*') {
          return key;
        }
        return '';
      }

      return key;
    });
  }

  getTextInputEdited = () => {
    const newArray = this.state.templateSelected.split('');

    return newArray.map((key, index) => {
      if (key === '*') {
        if (index === 0 || newArray[index - 1] !== '\\') {
          return (
            <input
              value={this.state.auxTemplateSelected[index] === '*' ? '' : this.state.auxTemplateSelected[index]}
              onChange={(e) => this.changeTemplateSelected(e, index)}
            />
          );
        }
        return key;
      } if (key === '\\') {
        if (index === (newArray.length - 1) || newArray[index + 1] !== '*') {
          return key;
        }
        return '';
      }
      return key;
    });
  }

  cancelTemplate = (from = 'templates') => {
    templateParams = {};

    this.setState({
      templateSelected: '',
      isTemplateSelected: false,
      auxTemplateSelected: [],
      templateEdited: false
    });

    from === 'templates' ? this.toggleModal() : this.toggleReminderConfigModal();
  }

  sendTemplate = () => {
    let allFilled = true;
    let file = null;

    this.state.auxTemplateSelected.forEach((key, index) => {
      if (key === '*' && (index === 0 || this.state.auxTemplateSelected[index - 1] !== '\\')) {
        allFilled = false;
      }
    });

    if (this.state.templateType !== 'text') {
      // eslint-disable-next-line prefer-destructuring
      file = document.getElementById('template_file').files[0];
    }

    const fileSelected = this.state.templateType === 'text' || file;

    if (allFilled && fileSelected) {
      let message = this.state.auxTemplateSelected.join('').replace(/(\r)/gm, "");
      message = this.getCleanTemplate(message);

      if (file) {
        if (this.state.templateType === 'image' && this.validateImages(file) === false) {
          alert('La imagen debe ser JPG/JPEG o PNG, de m??ximo 5MB');
          return;
        }

        if (this.state.templateType === 'document' && this.validFile(file) === false) return;
        if (this.state.templateType === 'video' && this.validVideo(file) === false) return;

        const data = new FormData();
        data.append('template', true);
        data.append('file_data', file);
        data.append('type', this.state.templateType);
        data.append('caption', message);
        this.handleSubmitImg(null, data);
      } else {
        this.handleSubmitWhatsAppMessage(null, message, true);
      }

      this.cancelTemplate();
    } else {
      const alertMessage = allFilled
        ? 'Debe seleccionar una Imagen o archivo PDF'
        : 'Debe llenar todos los campos editables';
      alert(alertMessage);
    }
  }

  handleAgentAssignment = (e) => {
    const value = parseInt(e.value, 10);
    const agent = this.props.agent_list.filter((currentAgent) => currentAgent.id === value);

    const r = confirm("Est??s seguro de asignar este chat a otro agente?");
    if (r === true) {
      const params = {
        agent: {
          retailer_user_id: agent[0] ? agent[0].id : null,
          chat_service: 'whatsapp'
        }
      };

      this.props.customerDetails.assigned_agent.id = value;
      this.props.changeCustomerAgent(this.props.currentCustomer, params, csrfToken);
    }
  }

  toggleFastAnswers = () => {
    this.props.toggleFastAnswers();
  }

  removeSelectedProduct = () => {
    this.setState({ selectedProduct: null });
  }

  removeSelectedFastAnswer = () => {
    this.setState({ selectedFastAnswer: null });
  }

  divClasses = (message) => {
    let classes = message.direction === 'outbound'
      ? `message-by-retailer f-right ${(message.status === 'error' && message.will_retry === false ? ' error-message' : '')}`
      : 'message-by-customer';
    classes += ' main-message-container';
    if (message.note === true) classes += ' note-message';
    if (['voice', 'audio'].includes(this.fileType(message.content_media_type))) {
      classes += ' video-audio audio-background';
    } else if (['image', 'video', 'sticker'].includes(this.fileType(message.content_media_type))) {
      classes += ' no-background media-container';
    }
    return classes;
  }

  setNoRead = (e) => {
    e.preventDefault();
    this.props.setNoRead(this.props.currentCustomer, csrfToken);
  }

  toggleChatBot = () => {
    const params = {
      chat_service: 'whatsapp'
    };
    this.props.toggleChatBot(this.props.currentCustomer, params, csrfToken);
  }

  toggleBlockUser = () => {
    if (!this.props.customer?.blocked
      && confirm('Al bloquear este n??mero no recibir??s sus mensajes. Podr??s desbloquearlo luego.')) {
      this.props.toggleBlockUser(this.props.currentCustomer, csrfToken);
    } else if (this.props.customer?.blocked
      && confirm('Al desbloquear este n??mero podr??s recibir sus mensajes. Puedes bloquearlo luego.')) {
      this.props.toggleBlockUser(this.props.currentCustomer, csrfToken);
    }
  }

  toggleLoadImages = () => {
    this.setState((prevState) => ({
      showLoadImages: !prevState.showLoadImages,
      loadedImages: []
    }));
  }

  removeImage = (index) => {
    this.state.loadedImages.splice(index, 1);
    this.setState((prevState) => ({ loadedImages: prevState.loadedImages }));
  }

  pasteImages = (e, fromSelector) => {
    e.preventDefault();

    if (e.clipboardData || e.originalEvent.clipboardData) {
      const clipboard = e.clipboardData || e.originalEvent.clipboardData;
      const pos = clipboard.types.indexOf('Files');
      let file;

      if (pos !== -1) {
        if (clipboard.items) {
          file = clipboard.items[pos].getAsFile();
        } else if (clipboard.files) {
          // eslint-disable-next-line prefer-destructuring
          file = clipboard.files[0];
        }

        if (file) {
          if (!this.validateImages(file)) {
            this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER_WS);
            return;
          }

          this.setState((prevState) => ({
            loadedImages: prevState.loadedImages.concat(file),
            showLoadImages: true
          }));
        } else {
          this.displayErrorAlert(MAX_IMAGE_SIZE_TRANSFER_WS);
        }
      } else if (!fromSelector) {
        const text = clipboard.getData('text/plain');
        e.target.innerText = stringUtils.addStr(e.target.innerText, this.caretPosition, text);
        this.setFocus(this.caretPosition + text.length);
      }
    }

    this.maximizeInputText();
  }

  setFocus = (position) => {
    // eslint-disable-next-line no-undef
    if (ENV.CURRENT_AGENT_ROLE === 'Supervisor') {
      return;
    }

    const node = document.getElementById("divMessage");
    if (!node) return;

    let caret;
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

  getText = () => {
    const input = $('#divMessage');
    const txt = input.html();

    return txt.replace(/<br>/g, "\n").replace(/\&amp;/g, '&');
  }

  objectPresence = () => (
    ((this.state.selectedProduct && this.state.selectedProduct.attributes.image)
      || (this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url))
  )

  getLocation = () => {
    this.handleShowInputMenu();
    if (navigator.geolocation) {
      this.setState({
        showMap: true
      });
    } else {
      alert('La geolocalizaci??n no est?? soportada en este navegador');
    }
  }

  sendLocation = (position) => {
    const uuid = uuidv4();
    const params = {
      longitude: position.lng,
      latitude: position.lat,
      customer_id: this.props.currentCustomer,
      template: false,
      type: 'location',
      message_identifier: uuid
    };

    this.setState((prevState) => ({
      messages: prevState.messages.concat({
        content_type: 'location',
        content_location_latitude: params.latitude,
        content_location_longitude: params.longitude,
        direction: 'outbound',
        status: 'enqueued',
        created_time: new Date(),
        message_identifier: uuid
      }),
      new_message: true,
      showMap: false
    }), () => {
      this.props.sendWhatsAppMessage(params, csrfToken);
      this.scrollToBottom();
    });
  }

  toggleMap = () => {
    this.setState((prevState) => ({
      showMap: !prevState.showMap
    }));
  }

  // eslint-disable-next-line no-undef
  overwriteStyle = () => (ENV.CURRENT_AGENT_ROLE === 'Supervisor' ? { height: 'calc(100vh - 405px)' } : {})

  customerRemoved = () => (
    !this.props.removedCustomer
      || (
        this.props.removedCustomer
        && this.props.currentCustomer !== this.props.removedCustomerId
      )
  )

  canSendMessages = () => (
    this.props.currentCustomer !== 0
      && this.state.can_write
      && this.customerRemoved()
    // eslint-disable-next-line no-undef
      && ENV.CURRENT_AGENT_ROLE !== 'Supervisor'
  )

  isChatClosed = () => (
    this.props.currentCustomer !== 0
      && !this.state.can_write
      && this.customerRemoved()
  )

  chatAlreadyAssigned = () => (
    this.props.currentCustomer !== 0
      && this.props.removedCustomer
      && this.props.currentCustomer === this.props.removedCustomerId
  )

  recordAudio = () => {
    if (navigator.mediaDevices) {
      navigator.mediaDevices.getUserMedia({ audio: true })
        .then((stream) => {
          this.setState({ recordingAudio: true });
          this.timer = setInterval(() => {
            // eslint-disable-next-line react/no-access-state-in-setstate
            const totalSeconds = this.state.totalSeconds + 1;

            this.setState({
              totalSeconds,
              audioSeconds: this.pad(totalSeconds % 60),
              audioMinutes: this.pad(parseInt(totalSeconds / 60, 10))
            });
          }, 1000);

          this.cancelledAudio = false;
          this.mediaRecorder = new MediaRecorder(stream);
          this.mediaRecorder.start();

          this.chunks = [];
          this.mediaRecorder.ondataavailable = (e) => {
            this.chunks.push(e.data);
          };

          this.mediaRecorder.onstop = () => {
            if (this.cancelledAudio) {
              this.resetAudio(stream);
              return;
            }

            const blob = new Blob(this.chunks, { 'type': 'audio/aac' });

            if (blob.size > 10 * 1024 * 1024) {
              this.resetAudio(stream);
              alert('Error: La nota debe ser de menos de 10MB');
              return;
            }

            const url = URL.createObjectURL(blob);
            this.sendAudio(blob, url, stream);
          };
        }).catch(() => {
          alert('Para enviar notas de voz, debes permitir el acceso al micr??fono');
        });
    } else {
      alert('La grabaci??n de audio no est?? soportada en este navegador');
    }
  }

  pad = (val) => {
    const valString = `${val}`;

    if (valString.length < 2) {
      return `0${valString}`;
    }
    return valString;
  }

  cancelAudio = () => {
    this.cancelledAudio = true;
    this.mediaRecorder.stop();
  }

  resetAudio = (stream) => {
    this.setState({
      recordingAudio: false,
      totalSeconds: 0,
      audioMinutes: '00',
      audioSeconds: '00'
    });

    clearInterval(this.timer);
    stream.getTracks()[0].stop();
    this.chunks = [];
    this.mediaRecorder = null;
  }

  sendAudio = (blob, url, stream) => {
    const uuid = uuidv4();
    const data = new FormData();
    data.append('template', false);
    data.append('file_data', blob);
    data.append('type', 'audio');
    data.append('message_identifier', uuid);

    this.setState((prevState) => ({
      messages: prevState.messages.concat(
        {
          content_type: 'media',
          content_media_type: 'audio',
          content_media_url: url,
          direction: 'outbound',
          created_time: new Date(),
          message_identifier: uuid
        }
      )
    }), () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, data, csrfToken);
      this.scrollToBottom();
    });

    this.resetAudio(stream);
  }

  toggleEmojiPicker = () => {
    this.setState((prevState) => {
      const newShowEmojiPicker = !prevState.showEmojiPicker;
      return ({ showEmojiPicker: newShowEmojiPicker });
    });
  }

  insertEmoji = (emoji) => {
    const input = $('#divMessage');
    let text = input.text();
    const first = text.substring(0, this.caretPosition);
    const second = text.substring(this.caretPosition);

    if (text.length === 0) {
      this.caretPosition = 0;
    }

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

        if (range.commonAncestorContainer.parentNode === editableDiv) {
          this.caretPosition = range.endOffset;
        }
      }
    } else if (document.selection && document.selection.createRange) {
      range = document.selection.createRange();

      if (range.parentElement() === editableDiv) {
        const tempEl = document.createElement("span");
        editableDiv.insertBefore(tempEl, editableDiv.firstChild);

        const tempRange = range.duplicate();
        tempRange.moveToElementText(tempEl);
        tempRange.setEndPoint("EndToEnd", range);

        this.caretPosition = tempRange.text.length;
      }
    }

    this.maximizeInputText();
  }

  getCleanTemplate = (text) => text.replaceAll('\\*', '*')

  setTemplateType = (type) => {
    switch (type) {
      case 'text':
        return 'Texto';
      case 'image':
        return 'Imagen';
      case 'video':
        return 'Video';
      default:
        return 'PDF';
    }
  }

  validFile = (file) => {
    let isValidFile = true;

    if (file.type !== 'application/pdf') {
      isValidFile = false;
    }
    else {
      if (ENV.SEND_MAX_SIZE_FILES) {
        isValidFile = fileUtils.isMaxFileSize(file);
      }
      else {
        isValidFile =  fileUtils.isDefaultFileSize(file);
      }
    }

    if (!isValidFile) {
      this.displayFileErrorAlert();
    }

    return isValidFile;
  }

  validVideo = (file) => {
    let isValid = true;

    if (!['video/mp4', 'video/3gpp'].includes(file.type)) {
      isValid = false;
    } else {
      isValid = fileUtils.isValidVideoSizeForWs(file);
    }

    if (!isValid) {
      this.displayVideoErrorAlert(MAX_VIDEO_SIZE_TRANSFER_WS);
    }

    return isValid;
  }

  displayVideoErrorAlert(size) {
    const fileSize = fileUtils.sizeFileInMB(size);

    alert(`Error: Los archivos deben ser videos MP4 o 3GPP, de m??ximo ${fileSize}MB`);
  }

  displayFileErrorAlert() {
    let fileSize = fileUtils.sizeFileInMB(DEFAULT_FILE_SIZE_TRANSFER);

    if (ENV.SEND_MAX_SIZE_FILES) {
      fileSize = fileUtils.sizeFileInMB(MAX_FILE_SIZE_TRANSFER);
    }

    alert(`El archivo debe ser PDF, de m??ximo ${fileSize}MB`);
  }

  acceptedFiles = () => {
    let accepted = '';

    switch (this.state.templateType) {
      case 'image':
        accepted = 'image/jpg, image/jpeg, image/png';
        break;
      case 'document':
        accepted = 'application/pdf';
        break;
      case 'video':
        accepted = 'video/mp4, video/3gpp';
        break;
    }

    this.setState({ acceptedFiles: accepted });
  }

  openReminderConfigModal = () => {
    // eslint-disable-next-line no-undef
    if (this.props.customer.whatsapp_opt_in || ENV.INTEGRATION === '0' || this.opted_in) {
      this.toggleReminderConfigModal();
    } else if (this.opted_in === false) {
      this.verifyOptIn('reminders');
    }
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

  toggleDealModal = () => {
    this.setState((prevState) => ({
      isDealModalOpen: !prevState.isDealModalOpen
    }))
  }

  getCustomerDeals = () => {
    this.props.fetchCustomerDeals(this.props.currentCustomer);
  }

  toggleReminderConfigModal = () => {
    this.setState((prevState) => ({
      isReminderConfigModalOpen: !prevState.isReminderConfigModalOpen
    }));
  }

  verifyOptIn = (from) => {
    if (confirm('Tengo el permiso expl??cito de enviar mensajes a este n??mero (opt-in)')) {
      const id = this.props.currentCustomer;

      const requestOptions = {
        method: 'PATCH',
        headers: { 'X-CSRF-Token': csrfToken }
      };

      fetch(`/api/v1/accept_optin_for_whatsapp/${id}`, requestOptions)
        .then(async (response) => {
          const data = await response.json();
          if (response.ok) {
            this.opted_in = true;
            from === 'templates' ? this.toggleModal() : this.toggleReminderConfigModal();
            return Promise.resolve(response);
          }
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        });
    }
  }

  submitReminder = () => {
    let allFilled = true;
    let file = null;

    this.state.auxTemplateSelected.forEach((key, index) => {
      if (key === '*' && (index === 0 || this.state.auxTemplateSelected[index - 1] !== '\\')) {
        allFilled = false;
      }
    });

    if (this.state.templateType !== 'text') {
      // eslint-disable-next-line prefer-destructuring
      file = document.getElementById('template_file').files[0];
    }

    const fileSelected = this.state.templateType === 'text' || file;
    const time = document.getElementById('send_template_at').value;

    if (allFilled && fileSelected && time) {
      if (this.state.templateType === 'image' && this.validateImages(file) === false) {
        alert('La imagen debe ser JPG/JPEG o PNG, de m??ximo 5MB');
        return;
      }

      if (this.state.templateType === 'document' && this.validFile(file) === false) return;
      if (this.state.templateType === 'video' && this.validVideo(file) === false) return;

      const params = new FormData();
      params.append('reminder[customer_id]', this.props.currentCustomer);
      params.append('reminder[whatsapp_template_id]', templateSelectedId);
      params.append('reminder[send_at]', time);
      params.append('reminder[timezone]', new Date().toString().match(/([-\+][0-9]+)\s/)[1]);

      if (file) params.append('reminder[file]', file);

      const insertedParams = Object.values(templateParams);
      insertedParams.forEach((value) => params.append('reminder[content_params][]', value));

      this.props.createReminder(params, csrfToken);
      this.cancelTemplate('reminders');
    } else {
      let alertMessage = '';

      if (!allFilled) {
        alertMessage = 'Debe llenar todos los campos editables';
      } else if (!fileSelected) {
        alertMessage = 'Debe seleccionar una Imagen o archivo PDF';
      } else {
        alertMessage = 'Debe ingresar un horario de env??o';
      }

      alert(alertMessage);
    }
  }

  handleShowInputMenu = () => {
    this.setState((prevState) => ({
      showInputMenu: !prevState.showInputMenu
    }));
  }

  openProducts = () => {
    this.handleShowInputMenu();
    this.props.toggleProducts();
  }

  toggleOptions = () => this.setState(({ showOptions }) => ({ showOptions: !showOptions }))

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

  render() {
    let screen;
    if (this.state.templateEdited === false) {
      screen = this.getTextInput();
    } else {
      screen = this.getTextInputEdited();
    }

    const chatBoxClass = this.state.showOptions && this.props.onMobile
      ? 'chat__box chat__box-without-options'
      : `chat__box ${ this.state.inputFilled && 'maximize' }`;

    return (
      <div className="chat-messages-holder bottom-xs">
        {this.props.onMobile && (
          <MobileTopChatBar
            backToChatList={this.props.backToChatList}
            chatType="whatsapp"
            customerDetails={this.props.customerDetails}
            editCustomerDetails={this.props.editCustomerDetails}
          />
        )}
        { this.props.currentCustomer !== 0 && this.customerRemoved()
          && (
            <TopChatBar
              activeChatBot={this.props.activeChatBot}
              agentsList={this.props.agent_list}
              customerDetails={this.props.customerDetails}
              newAgentAssignedId={this.props.newAgentAssignedId}
              handleAgentAssignment={this.handleAgentAssignment}
              customer={this.props.customer}
              onMobile={this.props.onMobile}
              setNoRead={this.setNoRead}
              toggleChatBot={this.toggleChatBot}
              toggleOptions={this.toggleOptions}
              showOptions={this.state.showOptions}
              chatType='whatsapp'
              toggleBlockUser={this.toggleBlockUser}
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
              <div className={this.divClasses(message)}>
                <Message
                  key={message.id}
                  message={message}
                  handleMessageEvents={this.props.handleMessageEvents}
                  openImage={this.openImage}
                />
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef} />
        </div>
        {/* eslint-disable-next-line no-nested-ternary */}
        {this.props.customer?.blocked ? (
          <BlockedUserMessage toggleNoteModal={this.toggleNoteModal} />
        ) : (
          this.chatAlreadyAssigned() ? (
            <AlreadyAssignedChatLabel />
          ) : (
            // eslint-disable-next-line no-nested-ternary
            this.props.errorSendMessageStatus ? (
              <ErrorSendingMessageLabel text={this.props.errorSendMessageText} />
            ) : (
              this.isChatClosed() ? (
                <ClosedChannel
                  openModal={this.openModal}
                  openReminderConfigModal={this.openReminderConfigModal}
                  toggleNoteModal={this.toggleNoteModal}
                  toggleDealModal={this.toggleDealModal}
                />
              ) : (
                this.canSendMessages()
                && (
                  <MessageForm
                    allowSendVoice={this.props.allowSendVoice}
                    audioMinutes={this.state.audioMinutes}
                    audioSeconds={this.state.audioSeconds}
                    cancelAudio={this.cancelAudio}
                    getCaretPosition={this.getCaretPosition}
                    getLocation={this.getLocation}
                    handleFileSubmit={this.handleFileSubmit}
                    handleSubmit={this.handleSubmit}
                    insertEmoji={this.insertEmoji}
                    mediaRecorder={this.mediaRecorder}
                    onKeyPress={this.onKeyPress}
                    onMobile={this.props.onMobile}
                    pasteImages={this.pasteImages}
                    recordAudio={this.recordAudio}
                    recordingAudio={this.state.recordingAudio}
                    removeSelectedFastAnswer={this.removeSelectedFastAnswer}
                    removeSelectedProduct={this.removeSelectedProduct}
                    selectedFastAnswer={this.state.selectedFastAnswer}
                    selectedProduct={this.state.selectedProduct}
                    showEmojiPicker={this.state.showEmojiPicker}
                    toggleEmojiPicker={this.toggleEmojiPicker}
                    toggleFastAnswers={this.toggleFastAnswers}
                    toggleLoadImages={this.toggleLoadImages}
                    toggleProducts={this.props.toggleProducts}
                    openProducts={this.openProducts}
                    openReminderConfigModal={this.openReminderConfigModal}
                    openNoteModal={this.toggleNoteModal}
                    openDealModal={this.toggleDealModal}
                    showInputMenu={this.state.showInputMenu}
                    handleShowInputMenu={this.handleShowInputMenu}
                    wrapperInputMenu={this.wrapperInputMenu}
                    inputFilled={this.state.inputFilled}
                  />
                )
              )
            )
          )
        )}
        <TemplateSelectionModal
          acceptedFiles={this.state.acceptedFiles}
          cancelTemplate={this.cancelTemplate}
          getCleanTemplate={this.getCleanTemplate}
          isModalOpen={this.state.isModalOpen}
          isTemplateSelected={this.state.isTemplateSelected}
          onMobile={this.props.onMobile}
          screen={screen}
          selectTemplate={this.selectTemplate}
          sendTemplate={this.sendTemplate}
          setTemplateType={this.setTemplateType}
          templates={this.props.templates}
          templateType={this.state.templateType}
          toggleModal={this.toggleModal}
        />

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

        <ReminderConfigModal
          acceptedFiles={this.state.acceptedFiles}
          cancelTemplate={this.cancelTemplate}
          getCleanTemplate={this.getCleanTemplate}
          isModalOpen={this.state.isModalOpen}
          isTemplateSelected={this.state.isTemplateSelected}
          onMobile={this.props.onMobile}
          screen={screen}
          selectTemplate={this.selectTemplate}
          sendTemplate={this.sendTemplate}
          submitReminder={this.submitReminder}
          setTemplateType={this.setTemplateType}
          templates={this.props.templates}
          templateType={this.state.templateType}
          toggleModal={this.toggleModal}
          toggleReminderConfigModal={this.toggleReminderConfigModal}
          isReminderConfigModalOpen={this.state.isReminderConfigModalOpen}
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
            agents={this.props.agent_list}
            getCustomerDeals={this.getCustomerDeals}
          />
          :
          false
        }
      </div>
    );
  }
}

function mapStateToProps({  mainReducer: state }) {
  totalPages = state.total_pages || 0;

  return {
    messages: state.messages || [],
    message: state.message || '',
    totalPages: state.total_pages || 0,
    templates: state.templates || [],
    total_template_pages: state.total_template_pages || 0,
    agents: state.agents || [],
    agent_list: state.agent_list || [],
    handleMessageEvents: state.handle_message_events || false,
    recentInboundMessageDate: state.recentInboundMessageDate || null,
    errorSendMessageStatus: state.errorSendMessageStatus,
    errorSendMessageText: state.errorSendMessageText,
    customer: state.customer,
    allowSendVoice: state.allowSendVoice,
    loadingMoreMessages: state.loadingMoreMessages || false,
    funnelSteps: state.funnelSteps || {},
    fetchingFunnels: state.fetching_funnels || false
  };
}

function mapDispatch(dispatch) {
  return {
    sendWhatsAppMessage: (message, token) => {
      dispatch(sendWhatsAppMessage(message, token));
    },
    fetchWhatsAppMessages: (id, page = 1) => {
      dispatch(fetchWhatsAppMessages(id, page));
    },
    setLastMessages: (customerDetails) => {
      dispatch(setLastMessages(customerDetails));
    },
    sendWhatsAppImg: (id, body, token) => {
      dispatch(sendWhatsAppImg(id, body, token));
    },
    setWhatsAppMessageAsRead: (id, body, token) => {
      dispatch(setWhatsAppMessageAsRead(id, body, token));
    },
    fetchWhatsAppTemplates: () => {
      dispatch(fetchWhatsAppTemplates());
    },
    changeCustomerAgent: (id, body, token) => {
      dispatch(changeCustomerAgent(id, body, token));
    },
    setNoRead: (customerId, token) => {
      dispatch(setNoRead(customerId, token));
    },
    toggleChatBot: (customerId, params, token) => {
      dispatch(toggleChatBot(customerId, params, token));
    },
    sendWhatsAppBulkFiles: (id, body, token) => {
      dispatch(sendWhatsAppBulkFiles(id, body, token));
    },
    createReminder: (body, token) => {
      dispatch(createReminder(body, token));
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
    },
    sendWhatsAppMultipleAnswers: (id, body, token) => {
      dispatch(sendWhatsAppMultipleAnswers(id, body, token));
    },
    toggleBlockUser: (customerId, token) => {
      dispatch(toggleBlockUser(customerId, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
