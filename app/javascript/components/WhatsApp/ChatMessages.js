import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import moment from 'moment';
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
  createReminder
} from '../../actions/whatsapp_karix';
import ImagesSelector from '../shared/ImagesSelector';
import GoogleMap from '../shared/Map';
import Message from './Message';
import 'emoji-mart/css/emoji-mart.css';
import TopChatBar from './TopChatBar';
import ClosedChannel from './ClosedChannel';
import MessageForm from './MessageForm';
import AlreadyAssignedChatLabel from '../shared/AlreadyAssignedChatLabel';
import TemplateSelectionModal from './TemplateSelectionModal';
import MobileTopChatBar from '../shared/MobileTopChatBar';
import ErrorSendingMessageLabel from './ErrorSendingMessageLabel';
import ReminderConfigModal from './ReminderConfigModal';
import Lightbox from 'react-image-lightbox';
import 'react-image-lightbox/style.css';

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
      templatePage: 1,
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
      isOpenImage: false,
      imageUrl: null
    };
    this.bottomRef = React.createRef();
    this.opted_in = false;
    this.cancelledAudio = false;
    this.caretPosition = 0;
  }

  handleLoadMore = () => {
    const id = this.props.currentCustomer;
    if (totalPages > this.state.page) {
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
      this.props.fetchWhatsAppMessages(id);
    });

    this.props.fetchWhatsAppTemplates(this.templatePage, csrfToken);
    // eslint-disable-next-line no-undef
    socket.on("message_chat", (data) => this.updateChat(data));

    this.setFocus();
  }

  addArrivingMessage = (currentMessages, newMessage) => {
    // First remove message without Id to avoid duplication
    let newMessagesArray = currentMessages.filter((message) => message.id);
    // Then find and replace element if it exists
    const index = currentMessages.findIndex((el) => (
      el.id === newMessage.id
    ));
    if (index === -1) {
      newMessagesArray = newMessagesArray.concat(newMessage);
    } else {
      newMessagesArray = newMessagesArray.map((message) => ((newMessage.id === message.id) ? newMessage : message));
    }
    return newMessagesArray.sort(this.sortMessages());
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

  sortMessages = () => (
    (a, b) => {
      if (moment(a.created_time) === moment(b.created_time)) {
        return 0;
      }
      if (moment(a.created_time) > moment(b.created_time)) {
        return 1;
      }
      return -1;
    }
  )

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps(newProps) {
    if (newProps.messages !== this.props.messages) {
      const rDate = moment(newProps.recentInboundMessageDate).local();
      this.setState((prevState) => ({
        new_message: false,
        messages: newProps.messages.concat(prevState.messages),
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
    }

    if (newProps.selectedProduct) {
      this.state.selectedProduct = newProps.selectedProduct;
      let productString = '';
      productString += (`${this.state.selectedProduct.attributes.title}\n`);
      productString += (`Precio $${this.state.selectedProduct.attributes.price}\n`);
      productString += (`${this.state.selectedProduct.attributes.description}\n`);
      productString += (this.state.selectedProduct.attributes.url ? this.state.selectedProduct.attributes.url : '');
      $('#divMessage').html(productString);
      this.props.selectProduct(null);
      this.removeSelectedFastAnswer();
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
        this.props.fetchWhatsAppMessages(id);
      });

      this.props.fetchWhatsAppTemplates(this.templatePage, csrfToken);
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
    if (e.which === 13) {
      e.preventDefault();
      this.handleSubmit(e);
    }
  }

  handleSubmit = (e) => {
    this.setState({
      showEmojiPicker: false
    });

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
        });
      }
    });

    this.setFocus();
  }

  handleSubmitWhatsAppMessage = (e, message, isTemplate) => {
    if (e) {
      e.preventDefault();
    }

    const text = {
      message, customer_id: this.props.currentCustomer, template: isTemplate, type: 'text'
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
        created_time: new Date()
      }),
      new_message: true
    }), () => {
      this.props.sendWhatsAppMessage(text, csrfToken);
      this.scrollToBottom();
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
      alert('Error: Máximo 5 imágenes permitidas');
      return;
    }

    let showError = false;

    Object.values(files).forEach((file) => {
      if (this.validateImages(file)) {
        if (this.state.loadedImages.length >= 5) {
          alert('Error: Máximo 5 imágenes permitidas');
          return;
        }
        this.setState((prevState) => ({ loadedImages: prevState.loadedImages.concat(file) }));
      } else {
        showError = true;
      }
    });

    if (showError || !files || files.length === 0) {
      alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
    }
  }

  validateImages = (file) => (
    ['image/jpg', 'image/jpeg', 'image/png'].includes(file.type)
    || file.size <= 5 * 1024 * 1024
  )

  sendImages = () => {
    const insertedMessages = [];
    const data = new FormData();
    data.append('template', false);
    this.state.loadedImages.forEach((image) => {
      data.append('file_data[]', image);

      const url = URL.createObjectURL(image);
      const type = this.fileType(image.type);
      const caption = type === 'document' ? image.name : null;

      insertedMessages.push({
        content_type: 'media',
        content_media_type: type,
        content_media_url: url,
        direction: 'outbound',
        content_media_caption: caption,
        created_time: new Date()
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
    const input = $('#divMessage');
    const data = new FormData();

    if (this.state.selectedProduct || this.state.selectedFastAnswer) {
      url = this.state.selectedProduct
        ? this.state.selectedProduct.attributes.image
        : this.state.selectedFastAnswer.attributes.image_url;
      type = 'image';
      caption = this.getText();

      data.append('template', false);
      data.append('url', url);
      data.append('type', 'file');
      data.append('caption', caption);
    } else if (fileData && fileData.get('template') === 'true') {
      const auxFile = fileData.get('file_data');

      url = URL.createObjectURL(auxFile);
      type = this.fileType(auxFile.type);
      filename = type === 'document' ? auxFile.name : null;
      caption = fileData.get('caption');
    } else {
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
          created_time: new Date()
        }
      ),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }), () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, fileData || data, csrfToken);
      input.html(null);
      this.scrollToBottom();
    });
  }

  handleFileSubmit = (e) => {
    const el = e.target;
    const file = el.files[0];

    if (
      !['application/pdf', 'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
        .includes(file.type)) {
      alert('Error: El archivo debe ser de tipo PDF o Word');
      return;
    }

    // Max 20 Mb allowed
    if (file.size > 20 * 1024 * 1024) {
      alert('Error: Maximo permitido 20MB');
      return;
    }

    const data = new FormData();
    data.append('file_data', file);
    data.append('template', false);
    this.handleSubmitImg(el, data);
  }

  fileType = (type) => {
    if (type == null) {
      return type;
    } if (type.includes('image/') || type === 'image') {
      return 'image';
    } if (['application/pdf', 'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(type)
      || type === 'document') {
      return 'document';
    } if (type.includes('audio/') || ['audio', 'voice'].includes(type)) {
      return 'audio';
    } if (type.includes('video/') || type === 'video') {
      return 'video';
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
        if (this.state.templateType === 'image' && this.validateImages(file) === false) return;
        if (this.state.templateType === 'file' && this.validFile(file) === false) return;

        const data = new FormData();
        data.append('template', true);
        data.append('file_data', file);
        data.append('type', 'file');
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
    const value = parseInt(e.target.value, 10);
    const agent = this.props.agent_list.filter((currentAgent) => currentAgent.id === value);

    const r = confirm("Estás seguro de asignar este chat a otro agente?");
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
      ? 'message-by-retailer f-right'
      : 'message-by-customer';
    classes += ' main-message-container';
    if (message.status === 'read'
      && this.props.handleMessageEvents === true) {
      classes += ' read-message';
    }
    if (['voice', 'audio'].includes(this.fileType(message.content_media_type))) {
      classes += ' video-audio no-background';
    } else if (['image', 'video'].includes(this.fileType(message.content_media_type))) {
      classes += ' no-background media-container';
    }
    return classes;
  }

  setNoRead = (e) => {
    e.preventDefault();
    this.props.setNoRead(this.props.currentCustomer, csrfToken);
  }

  toggleChatBot = (e) => {
    e.preventDefault();
    this.props.toggleChatBot(this.props.currentCustomer, csrfToken);
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
            alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
            return;
          }

          this.setState((prevState) => ({
            loadedImages: prevState.loadedImages.concat(file),
            showLoadImages: true
          }));
        } else {
          alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
        }
      } else if (!fromSelector) {
        const text = clipboard.getData('text/plain');
        document.execCommand('insertText', false, text);
      }
    }
  }

  setFocus = (position) => {
    // eslint-disable-next-line no-undef
    if (ENV.CURRENT_AGENT_ROLE === 'Supervisor') {
      return;
    }

    const node = document.getElementById("divMessage");
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
      const textNode = node.firstChild;
      const range = document.createRange();
      range.setStart(textNode, caret);
      range.setEnd(textNode, caret);

      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }

    this.caretPosition = caret;
  }

  getText = () => {
    const input = $('#divMessage');
    const txt = input.html();

    return txt.replace(/<br>/g, "\n");
  }

  objectPresence = () => (
    ((this.state.selectedProduct && this.state.selectedProduct.attributes.image)
      || (this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url))
  )

  getLocation = () => {
    if (navigator.geolocation) {
      this.setState({
        showMap: true
      });
    } else {
      alert('La geolocalización no está soportada en este navegador');
    }
  }

  sendLocation = (position) => {
    const params = {
      longitude: position.lng,
      latitude: position.lat,
      customer_id: this.props.currentCustomer,
      template: false,
      type: 'location'
    };

    this.setState((prevState) => ({
      messages: prevState.messages.concat({
        content_type: 'location',
        content_location_latitude: params.latitude,
        content_location_longitude: params.longitude,
        direction: 'outbound',
        status: 'enqueued',
        created_time: new Date()
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
  overwriteStyle = () => (ENV.CURRENT_AGENT_ROLE === 'Supervisor' ? { height: '80vh' } : {})

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
          alert('Para enviar notas de voz, debes permitir el acceso al micrófono');
        });
    } else {
      alert('La grabación de audio no está soportada en este navegador');
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
    const data = new FormData();
    data.append('template', false);
    data.append('file_data', blob);
    data.append('type', 'audio');

    this.setState((prevState) => ({
      messages: prevState.messages.concat(
        {
          content_type: 'media',
          content_media_type: 'audio',
          content_media_url: url,
          direction: 'outbound',
          created_time: new Date()
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
  }

  getCaretPosition = () => {
    let sel; let range; const
      editableDiv = document.getElementById('divMessage');

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
  }

  getCleanTemplate = (text) => text.replaceAll('\\*', '*')

  setTemplateType = (type) => {
    if (type === 'text') {
      return 'Texto';
    } if (type === 'image') {
      return 'Imagen';
    }
    return 'PDF';
  }

  validFile = (file) => {
    if (file.type !== 'application/pdf' || file.size > 20 * 1024 * 1024) {
      alert('El archivo debe ser PDF, de máximo 20MB');
      return false;
    }

    return true;
  }

  acceptedFiles = () => {
    let accepted = '';

    if (this.state.templateType === 'image') {
      accepted = 'image/jpg, image/jpeg, image/png';
    } else if (this.state.templateType === 'file') {
      accepted = 'application/pdf';
    }

    this.setState({ acceptedFiles: accepted });
  }

  openReminderConfigModal = () => {
    // eslint-disable-next-line no-undef
    if (this.props.customer.whatsapp_opt_in || ENV.INTEGRATION === '0' || this.opted_in) {
      this.toggleReminderConfigModal();
    } else if (this.opted_in === false) {
      this.verifyOptIn('reminders')
    }
  }

  toggleReminderConfigModal = () => {
    this.setState((prevState) => ({
      isReminderConfigModalOpen: !prevState.isReminderConfigModalOpen
    }));
  }

  verifyOptIn = (from) => {
    if (confirm('Tengo el permiso explícito de enviar mensajes a este número (opt-in)')) {
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
        alert('La imagen debe ser JPG/JPEG o PNG, de máximo 5MB')
        return;
      }

      if (this.state.templateType === 'file' && this.validFile(file) === false) return;

      let params = new FormData();
      params.append('reminder[customer_id]', this.props.currentCustomer);
      params.append('reminder[whatsapp_template_id]', templateSelectedId);
      params.append('reminder[send_at]', time);
      params.append('reminder[timezone]', new Date().toString().match(/([-\+][0-9]+)\s/)[1]);

      if (file) params.append('reminder[file]', file);

      const insertedParams = Object.values(templateParams);
      params.append('reminder[content_params]', JSON.stringify(insertedParams));

      this.props.createReminder(params, csrfToken)
      this.cancelTemplate('reminders');
    } else {
      let alertMessage = '';

      if (!allFilled) {
        alertMessage = 'Debe llenar todos los campos editables';
      } else if (!fileSelected) {
        alertMessage = 'Debe seleccionar una Imagen o archivo PDF';
      } else {
        alertMessage = 'Debe ingresar un horario de envío';
      }

      alert(alertMessage);
    }
  }

  render() {
    let screen;
    if (this.state.templateEdited === false) {
      screen = this.getTextInput();
    } else {
      screen = this.getTextInputEdited();
    }

    return (
      <div className="row bottom-xs">
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
          className="col-xs-12 chat__box pt-8"
          onScroll={(e) => this.handleScrollToTop(e)}
          style={this.overwriteStyle()}
        >
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
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
        {this.chatAlreadyAssigned() ? (
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
                allowReminders={this.props.allowReminders}
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
                  openReminderConfigModal={this.openReminderConfigModal}
                  allowReminders={this.props.allowReminders}
                />
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
      </div>
    );
  }
}

function mapStateToProps(state) {
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
    allowReminders: state.allowReminders
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
    sendWhatsAppImg: (id, body, token) => {
      dispatch(sendWhatsAppImg(id, body, token));
    },
    setWhatsAppMessageAsRead: (id, body, token) => {
      dispatch(setWhatsAppMessageAsRead(id, body, token));
    },
    fetchWhatsAppTemplates: (page = 1, token) => {
      dispatch(fetchWhatsAppTemplates(page, token));
    },
    changeCustomerAgent: (id, body, token) => {
      dispatch(changeCustomerAgent(id, body, token));
    },
    setNoRead: (customerId, token) => {
      dispatch(setNoRead(customerId, token));
    },
    toggleChatBot: (customerId, token) => {
      dispatch(toggleChatBot(customerId, token));
    },
    sendWhatsAppBulkFiles: (id, body, token) => {
      dispatch(sendWhatsAppBulkFiles(id, body, token));
    },
    createReminder: (body, token) => {
      dispatch(createReminder(body, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
