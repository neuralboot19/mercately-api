import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import {
  sendWhatsAppMessage,
  fetchWhatsAppMessages,
  sendWhatsAppImg,
  setWhatsAppMessageAsRead,
  fetchWhatsAppTemplates,
  changeCustomerAgent,
  setNoRead,
  toggleChatBot,
  sendWhatsAppBulkFiles } from "../../actions/whatsapp_karix";
import Modal from 'react-modal';
import ImagesSelector from './../shared/ImagesSelector';
import GoogleMap from './../shared/Map';
import 'emoji-mart/css/emoji-mart.css';
import { Picker } from 'emoji-mart';

var currentCustomer = 0;
var total_pages = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content
const pickerI18n = {
  search: 'Buscar emoji',
  clear: 'Limpiar',
  notfound: 'Emoji no encontrado',
  skintext: 'Selecciona el tono de piel por defecto',
  categories: {
    search: 'Resultados de la búsqueda',
    recent: 'Recientes',
    smileys: 'Smileys & Emotion',
    people: 'Emoticonos y personas',
    nature: 'Animales y naturaleza',
    foods: 'Alimentos y bebidas',
    activity: 'Actividades',
    places: 'Viajes y lugares',
    objects: 'Objetos',
    symbols: 'Símbolos',
    flags: 'Banderas',
    custom: 'Custom',
  },
  categorieslabel: 'Categorías de los emojis',
  skintones: {
    1: 'Tono de piel por defecto',
    2: 'Tono de piel claro',
    3: 'Tono de piel claro medio',
    4: 'Tono de piel medio',
    5: 'Tono de piel oscuro medio',
    6: 'Tono de piel oscuro',
  }
}

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

class ChatMessages extends Component {
  constructor(props) {
    super(props)
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
      showEmojiPicker: false
    };
    this.bottomRef = React.createRef();
    this.opted_in = false;
    this.cancelledAudio = false;
    this.caretPosition = 0;
  }

  handleLoadMore = () => {
    let id = this.props.currentCustomer;
    if (total_pages > this.state.page) {
      this.setState({ page: this.state.page += 1, load_more: true, scrolable: false}, () => {
        this.props.fetchWhatsAppMessages(id, this.state.page);
      });
    }
  }

  componentDidMount() {
    let id = this.props.currentCustomer;
    this.opted_in = this.props.customerDetails.whatsapp_opt_in;
    currentCustomer = id;

    this.setState({
      messages: [],
      page: 1,
      scrolable: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }, () => {
      this.props.fetchWhatsAppMessages(id);
      this.scrollToBottom();
    });

    this.props.fetchWhatsAppTemplates(this.templatePage, csrfToken);
    socket.on("message_chat", data => this.updateChat(data));

    this.setFocus();
  }

  updateChat = (data) => {
    var karix_message = data.karix_whatsapp_message.karix_whatsapp_message;
    if (currentCustomer == karix_message.customer_id) {
      if (karix_message.content_type == 'text') {
        if (!this.state.new_message) {
          var messages = this.state.messages;
          var message_id = karix_message.id;

          messages = this.removeByTextArray(messages, karix_message.content_text, message_id);
          var index = this.findMessageInArray(messages, message_id);

          if (index === -1) {
            this.setState({
              messages: this.state.messages.concat(karix_message).sort(this.sortMessages()),
              new_message: false,
              updated: false
            }, () => this.setState({ updated: true}))
          }
        }
      } else if ((['image', 'voice', 'audio', 'video', 'document'].includes(karix_message.content_media_type) || ['location', 'contact'].includes(karix_message.content_type)) &&
        karix_message.direction === 'inbound') {
        this.setState({
          messages: this.state.messages.concat(karix_message),
          new_message: false,
        })
      }

      if (karix_message.direction === 'inbound') {
        this.props.setWhatsAppMessageAsRead(currentCustomer, {message_id: karix_message.id}, csrfToken);
        this.state.can_write = true;
      }
    }
  }

  sortMessages = () => {
    return function(a, b) {
      if (moment(a.created_time) == moment(b.created_time)) {
        return 0;
      }
      if (moment(a.created_time) > moment(b.created_time)) {
        return 1;
      }
      if (moment(a.created_time) < moment(b.created_time)) {
        return -1;
      }
    }
  }

  componentWillReceiveProps(newProps){
    if (newProps.messages != this.props.messages) {
      var rDate = moment(newProps.recentInboundMessageDate).local();
      this.setState({
        new_message: false,
        messages: newProps.messages.concat(this.state.messages),
        load_more: false,
        can_write: moment().local().diff(rDate, 'hours') < 24
      }, () => {
        this.opted_in = false
        if (this.props.customer !== undefined) {
          this.opted_in = this.props.customer.whatsapp_opt_in || false
        }
      })
    }

    if (newProps.selectedFastAnswer) {
      this.state.selectedFastAnswer = newProps.selectedFastAnswer;
      $('#divMessage').html(this.state.selectedFastAnswer.attributes.answer);
      this.props.changeFastAnswer(null);
      this.removeSelectedProduct();
    }

    if (newProps.selectedProduct) {
      this.state.selectedProduct = newProps.selectedProduct;
      var productString = '';
      productString += (this.state.selectedProduct.attributes.title + '\n');
      productString += ('Precio $' + this.state.selectedProduct.attributes.price + '\n');
      productString += (this.state.selectedProduct.attributes.description + '\n');
      productString += (this.state.selectedProduct.attributes.url ? this.state.selectedProduct.attributes.url : '');
      $('#divMessage').html(productString);
      this.props.selectProduct(null);
      this.removeSelectedFastAnswer();
    }
  }

  componentDidUpdate() {
    let id = this.props.currentCustomer;
    var rDate = moment(this.props.recentInboundMessageDate).local();
    if (this.state.new_message) {
      this.setState({
        can_write: moment().local().diff(rDate, 'hours') < 24,
        new_message: false
      })
    }

    if (currentCustomer !== id) {
      currentCustomer = id;
      total_pages = 0;
      this.scrollToBottom();
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
    }

    if (this.state.scrolable) {
      this.scrollToBottom();
    }
  }

  scrollToBottom = () => {
    this.bottomRef.current.scrollIntoView();
  }

  handleInputChange = (e) => {
    this.setState({
      [e.target.name]: e.target.value
    })
  }

  onKeyPress = (e) => {
    if(e.which === 13) {
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

    let input = $('#divMessage');
    let text = input.text();
    if(text.trim() === '') return;

    let txt = this.getText();
    var rDate = moment(this.props.recentInboundMessageDate).local();
    this.setState({
      can_write: moment().local().diff(rDate, 'hours') < 24
    }, () => {
      if (this.state.can_write) {
        this.setState({ selectedProduct: null, selectedFastAnswer: null }, () => {
          this.handleSubmitWhatsAppMessage(e, txt, false)
          input.html(null);
        });
      }
    })

    this.setFocus();
  }

  handleSubmitWhatsAppMessage = (e, message, isTemplate) => {
    if (e) {
      e.preventDefault();
    }

    let text = { message: message, customer_id: this.props.currentCustomer, template: isTemplate, type: 'text' }
    this.setState({ messages: this.state.messages.concat({
      content_type: 'text',
      content_text: message,
      direction: 'outbound',
      status: 'enqueued',
      created_time: new Date()
    }), new_message: true}, () => {
      this.props.sendWhatsAppMessage(text, csrfToken);
      this.scrollToBottom();
    });
  }

  findMessageInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  removeByTextArray = (arr, text, id=null) => {
    let index;

    if (id) {
      index = arr.findIndex((el) => el.content_text === text && el.id === id)
      if (index === -1) {
        index = arr.findIndex((el) => el.content_text === text && !el.id)
      }
    } else {
      index = arr.findIndex((el) => el.content_text === text && !el.id)
    }

    if (index !== -1) {
      arr.splice(index, 1);
    }

    return arr
  }

  handleScrollToTop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    if(el.scrollTop >= 0 && el.scrollTop <= 5) {
      el.scrollTop = 10;
      this.handleLoadMore();
    }
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

    if (showError || !files || files.length == 0) {
      alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
    }
  }

  validateImages = (file) => {
    if (!['image/jpg', 'image/jpeg', 'image/png'].includes(file.type) || file.size > 5*1024*1024) {
      return false;
    }

    return true;
  }

  sendImages = () => {
    var insertedMessages = [];
    var data = new FormData();
    data.append('template', false);
    this.state.loadedImages.map((image) => {
      data.append('file_data[]', image);

      var url = URL.createObjectURL(image);
      var type = this.fileType(image.type);
      var caption = type == 'document' ? image.name : null;

      insertedMessages.push({content_type: 'media', content_media_type: type, content_media_url: url, direction: 'outbound', content_media_caption: caption, created_time: new Date()})
    });

    this.setState({
      messages: this.state.messages.concat(insertedMessages),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    });

    this.props.sendWhatsAppBulkFiles(this.props.currentCustomer, data, csrfToken);
    this.scrollToBottom();
    this.toggleLoadImages();
  }

  handleImgSubmit = (e) => {
    var el = e.target;
    var file = el.files[0];
    if (!this.validateImages(file)) {
      alert('Error: El archivo debe ser una imagen JPG/JPEG o PNG, de máximo 5MB');
      return;
    }

    var data = new FormData();
    data.append('file_data', file);
    data.append('template', false);
    this.handleSubmitImg(el, data);
  }

  handleSubmitImg = (el, file_data) => {
    var url, type, caption;
    var input = $('#divMessage');

    if (this.state.selectedProduct || this.state.selectedFastAnswer) {
      url = this.state.selectedProduct ? this.state.selectedProduct.attributes.image : this.state.selectedFastAnswer.attributes.image_url;
      type = 'image';
      caption = this.getText();

      var data = new FormData();
      data.append('template', false);
      data.append('url', url);
      data.append('type', 'file');
      data.append('caption', caption);
    } else {
      url = URL.createObjectURL(el.files[0]);
      type = this.fileType(el.files[0].type);
      caption = type == 'document' ? el.files[0].name : null;
    }

    this.setState({
      messages: this.state.messages.concat({content_type: 'media', content_media_type: type, content_media_url: url, direction: 'outbound', content_media_caption: caption, created_time: new Date()}),
      new_message: true,
      selectedProduct: null,
      selectedFastAnswer: null
    }, () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, file_data ? file_data : data, csrfToken);
      input.html(null);
      this.scrollToBottom();
    });
  }

  handleFileSubmit = (e) => {
    var el = e.target;
    var file = el.files[0];

    if(!['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(file.type)) {
      alert('Error: El archivo debe ser de tipo PDF o Word');
      return;
    }

    // Max 20 Mb allowed
    if(file.size > 20*1024*1024) {
      alert('Error: Maximo permitido 20MB');
      return;
    }

    var data = new FormData();
    data.append('file_data', file);
    data.append('template', false);
    this.handleSubmitImg(el, data);
  }

  fileType = (file_type) => {
    if (file_type == null) {
      return file_type;
    } else if (file_type.includes('image/') || file_type == 'image') {
      return 'image';
    } else if (['application/pdf', 'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(file_type) ||
      file_type == 'document') {
        return 'document';
    } else if (file_type.includes('audio/') || ['audio', 'voice'].includes(file_type)) {
      return 'audio';
    } else if (file_type.includes('video/') || file_type == 'video') {
      return 'video';
    }
  }

  downloadFile = (e, file_url, filename) => {
    e.preventDefault();
    var link = document.createElement('a');
    link.href = file_url;
    link.target = '_blank';
    link.download = filename;
    link.click();
  }

  toggleImgModal = (e) => {
    var el = e.target;

    this.setState({
      url: el.src,
      isImgModalOpen: !this.state.isImgModalOpen
    });
  }

  openModal = () => {
    if (this.props.customer.whatsapp_opt_in || ENV['INTEGRATION'] == '0' || this.opted_in) {
      this.toggleModal();
    } else {
      if (this.opted_in == false) {
        if (confirm('Tengo el permiso explícito de enviar mensajes a este número (opt-in)')) {
          var id = this.props.currentCustomer;

          const requestOptions = {
              method: 'PATCH',
              headers: { 'X-CSRF-Token': csrfToken }
          };

          fetch('/api/v1/accept_optin_for_whatsapp/' + id, requestOptions)
          .then(async response => {
              const data = await response.json();

              if (response.ok) {
                this.opted_in = true;
                this.toggleModal();
              } else {
                const error = (data && data.message) || response.status;
                return Promise.reject(error);
              }
          });
        }
      }
    }
  }

  toggleModal = () => {
    this.setState({
      isModalOpen: !this.state.isModalOpen
    });
  }

  selectTemplate = (template) => {
    this.setState({
      isTemplateSelected: true,
      templateSelected: template.text,
      auxTemplateSelected: template.text.split('')
    });
  }

  changeTemplateSelected = (e, id) => {
    this.state.templateSelected.split('').map((key, index) => {
      if (key == '*'){
        if (index == id && e.target.value && e.target.value !== '') {
          this.state.auxTemplateSelected[index] = e.target.value;
        } else if (index == id && (!e.target.value || e.target.value === '')) {
          this.state.auxTemplateSelected[index] = '*';
        }
      }
    })

    this.setState({
      templateEdited: true
    });
  }

  getTextInput = () => {
    let new_array = this.state.templateSelected.split('')
    return new_array.map((key, index) => {
      if (key == '*'){
        return <input value='' onChange={ (e) => this.changeTemplateSelected(e, index)} /> ;
      } else {
        return key
      }
    })
  }

  getTextInputEdited = () => {
    let new_array = this.state.templateSelected.split('')
    return new_array.map((key, index) => {
      if (key == '*'){
        return <input value={this.state.auxTemplateSelected[index] === '*' ? '' : this.state.auxTemplateSelected[index] } onChange={ (e) => this.changeTemplateSelected(e, index)}   /> ;
      } else {
        return key
      }
    })
  }

  cancelTemplate = () => {
    this.setState({
      templateSelected: '',
      isTemplateSelected: false,
      auxTemplateSelected: [],
      templateEdited: false
    })

    this.toggleModal();
  }

  sendTemplate = () => {
    var allFilled = true;
    this.state.auxTemplateSelected.map((key) => {
      if (key === '*') {
        allFilled = false;
      }
    })

    if (allFilled) {
      var message = this.state.auxTemplateSelected.join('').replace(/(\r)/gm, "");

      this.handleSubmitWhatsAppMessage(null, message, true);
      this.cancelTemplate();
    } else {
      alert('Debe llenar todos los campos editables');
    }
  }

  handleAgentAssignment = (e) => {
    var value = parseInt(e.target.value);
    var agent = this.props.agent_list.filter(agent => agent.id === value);

    var r = confirm("Estás seguro de asignar este chat a otro agente?");
    if (r == true) {
      var params = {
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
    var classes = message.direction == 'outbound' ? 'message-by-retailer f-right' : 'message-by-customer';
    classes += ' main-message-container';
    if (message.status == 'read' && message.content_type == 'text' && this.props.handleMessageEvents === true)
      classes += ' read-message';
    if (['voice', 'audio', 'video'].includes(this.fileType(message.content_media_type))) classes += ' video-audio no-background';
    if (this.fileType(message.content_media_type) === 'image') classes += ' no-background';
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
    this.setState({
      showLoadImages: !this.state.showLoadImages,
      loadedImages: []
    });
  }

  removeImage = (index) => {
    this.state.loadedImages.splice(index, 1);
    this.setState({ loadedImages: this.state.loadedImages });
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
            alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
            return;
          }

          this.setState({
            loadedImages: this.state.loadedImages.concat(file),
            showLoadImages: true
          })
        } else {
          alert('Error: Los archivos deben ser imágenes JPG/JPEG o PNG, de máximo 5MB');
        }
      } else {
        if (!fromSelector) {
          var text = clipboard.getData('text/plain');
          document.execCommand('insertText', false, text);
        }
      }
    }
  }

  setFocus = (position) => {
    if (ENV['CURRENT_AGENT_ROLE'] === 'Supervisor')
      return true;

    let node = document.getElementById("divMessage");
    let caret = 0;
    let input = $(node);
    let text = input.text();

    node.focus();

    if (position) {
      caret = position;
    } else {
      caret = text.length;
    }

    if (caret > 0) {
      let textNode = node.firstChild;
      let range = document.createRange();
      range.setStart(textNode, caret);
      range.setEnd(textNode, caret);

      let sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }

    this.caretPosition = caret;
  }

  getText = () => {
    let input = $('#divMessage');
    let txt = input.html();

    return txt.replace(/<br>/g, "\n");
  }

  objectPresence = () => {
    if ((this.state.selectedProduct && this.state.selectedProduct.attributes.image) ||
      (this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url)) {
        return true;
      }

    return false;
  }

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
    let params = {
      longitude: position.lng,
      latitude: position.lat,
      customer_id: this.props.currentCustomer,
      template: false,
      type: 'location'
    }

    this.setState({ messages: this.state.messages.concat({
      content_type: 'location',
      content_location_latitude: params.latitude,
      content_location_longitude: params.longitude,
      direction: 'outbound',
      status: 'enqueued',
      created_time: new Date()
    }), new_message: true, showMap: false}, () => {
      this.props.sendWhatsAppMessage(params, csrfToken);
      this.scrollToBottom();
    });
  }

  toggleMap = () => {
    this.setState({
      showMap: !this.state.showMap
    });
  }

  timeMessage = (message) => {
    return (
      <span className={message.direction == 'inbound' ? 'fs-10 mt-3 c-gray-label' : 'fs-10 mt-3'}>{moment(message.created_time).local().locale('es').format('DD-MM-YYYY HH:mm')}</span>
    )
  }

  overwriteStyle = () => {
    return ENV['CURRENT_AGENT_ROLE'] === 'Supervisor' ? { height: '80vh'} : {}
  }

  customerRemoved = () => {
    return (
      !this.props.removedCustomer ||
      (
        this.props.removedCustomer &&
        this.props.currentCustomer !== this.props.removedCustomerId
      )
    );
  }

  canSendMessages = () => {
    return (
      this.props.currentCustomer != 0 &&
      this.state.can_write &&
      this.customerRemoved() &&
      ENV['CURRENT_AGENT_ROLE'] !== 'Supervisor'
    );
  }

  isChatClosed = () => {
    return (
      this.props.currentCustomer != 0 &&
      !this.state.can_write &&
      this.customerRemoved()
    );
  }

  chatAlreadyAssigned = () => {
    return (
      this.props.currentCustomer != 0 &&
      this.props.removedCustomer &&
      this.props.currentCustomer == this.props.removedCustomerId
    );
  }

  recordAudio = () => {
    if (navigator.mediaDevices) {
      navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.setState({recordingAudio: true});
        this.timer = setInterval(() => {
          let totalSeconds = this.state.totalSeconds + 1;

          this.setState({
            totalSeconds: totalSeconds,
            audioSeconds: this.pad(totalSeconds % 60),
            audioMinutes: this.pad(parseInt(totalSeconds / 60))
          });
        }, 1000);

        this.cancelledAudio = false;
        this.mediaRecorder = new MediaRecorder(stream);
        this.mediaRecorder.start();

        this.chunks = [];
        this.mediaRecorder.ondataavailable = (e) => {
          this.chunks.push(e.data);
        }

        this.mediaRecorder.onstop = () => {
          if (this.cancelledAudio) {
            this.resetAudio(stream);
            return;
          }

          let blob = new Blob(this.chunks, { 'type' : 'audio/aac' });

          if (blob.size > 10*1024*1024) {
            this.resetAudio(stream);
            alert('Error: La nota debe ser de menos de 10MB');
            return;
          }

          let url = URL.createObjectURL(blob);
          this.sendAudio(blob, url, stream);
        }
      }).catch(err => {
        alert('Para enviar notas de voz, debes permitir el acceso al micrófono');
      });
    } else {
      alert('La grabación de audio no está soportada en este navegador');
    }
  }

  pad = (val) => {
    var valString = val + "";

    if (valString.length < 2) {
      return "0" + valString;
    } else {
      return valString;
    }
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
    var data = new FormData();
    data.append('template', false);
    data.append('file_data', blob);
    data.append('type', 'audio');

    this.setState({
      messages: this.state.messages.concat(
        {
          content_type: 'media',
          content_media_type: 'audio',
          content_media_url: url,
          direction: 'outbound',
          created_time: new Date()
        }
      )
    }, () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, data, csrfToken);
      this.scrollToBottom();
    });

    this.resetAudio(stream);
  }

  toggleEmojiPicker = () => {
    this.setState({
      showEmojiPicker: !this.state.showEmojiPicker
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
    let sel, range, editableDiv = document.getElementById('divMessage');

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

  render() {
    if (this.state.templateEdited == false){
      screen = this.getTextInput();
    } else {
      screen = this.getTextInputEdited();
    }

    return (
      <div className="row bottom-xs">
        {this.props.onMobile && (
          <div className="col-xs-12 row">
            <div className="col-xs-2 pl-0" onClick={() => this.props.backToChatList()}>
              <i className="fas fa-arrow-left c-secondary fs-30 mt-12"></i>
            </div>
            <div className="col-xs-8 pl-0">
              <div className="profile__name">
                {`${this.props.customerDetails.first_name && this.props.customerDetails.last_name  ? `${this.props.customerDetails.first_name} ${this.props.customerDetails.last_name}` : this.props.customerDetails.whatsapp_name ? this.props.customerDetails.whatsapp_name : this.props.customerDetails.phone}`}
              </div>
              <div className={this.props.customerDetails["unread_whatsapp_message?"] ? 'fw-bold' : ''}>
                <small>{moment(this.props.customerDetails.recent_message_date).locale('es').fromNow()}</small>
              </div>
            </div>
            <div className="col-xs-2 pl-0" onClick={() => this.props.editCustomerDetails()}>
              <div className="c-secondary mt-12">
                Editar
              </div>
            </div>
          </div>
        )}
        { this.props.currentCustomer != 0 && this.customerRemoved() &&
          (<div className="top-chat-bar pl-10">
            <div className='assigned-to'>
              <small>Asignado a: </small>
              <select id="agents" value={this.props.newAgentAssignedId || this.props.customerDetails.assigned_agent.id || ''} onChange={(e) => this.handleAgentAssignment(e)}>
                <option value="">No asignado</option>
                {this.props.agent_list.map((agent, index) => (
                  <option value={agent.id} key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
                ))}
              </select>
            </div>
            {this.props.activeChatBot && this.props.onMobile == false &&
              <div className="tooltip-top chat-bot-icon">
                <i className="fas fa-robot c-secondary fs-15"></i>
                <div className="tooltiptext">ChatBot Activo</div>
              </div>
            }
            <div className='mark-no-read'>
              <button onClick={(e) => this.setNoRead(e)} className='btn btn--cta btn-small right'>Marcar como no leído</button>
              <button onClick={(e) => this.toggleChatBot(e)} className='btn btn--cta btn-small right'>
                {this.props.activeChatBot || (this.props.customer && this.props.customer.allow_start_bots) ?
                  <span>Desactivar Bot</span>
                : <span>Activar Bot</span>
                }
              </button>
            </div>
          </div>
          )}
        {this.state.isImgModalOpen && (
          <div className="img_modal">
            <div className="img_modal__overlay" onClick={(e) => this.toggleImgModal(e)}>
            </div>
            <img src={this.state.url} />
          </div>
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)} style={this.overwriteStyle()}>
          {this.state.messages.map((message, index) => (
            <div key={index} className="message">
              <div className={ this.divClasses(message) } >
                {message.replied_message &&
                  <div className="replied-message mb-10">
                    {message.replied_message.data.attributes.content_type == 'text' &&
                      <span className="text text-pre-line">{message.replied_message.data.attributes.content_text}</span>
                    }
                    {message.replied_message.data.attributes.content_type == 'media' && message.replied_message.data.attributes.content_media_type == 'image' &&
                      <img src={message.replied_message.data.attributes.content_media_url} className="image"
                        onClick={(e) => this.toggleImgModal(e)}/>
                    }
                    {message.replied_message.data.attributes.content_type == 'media' && (message.replied_message.data.attributes.content_media_type == 'voice' || message.replied_message.data.attributes.content_media_type == 'audio') && (
                      <audio controls>
                        <source src={message.replied_message.data.attributes.content_media_url}/>
                      </audio>
                    )}
                    {message.replied_message.data.attributes.content_type == 'media' && message.replied_message.data.attributes.content_media_type == 'video' && (
                      <video width="120" height="80" controls>
                        <source src={message.replied_message.data.attributes.content_media_url}/>
                      </video>
                    )}
                    {message.replied_message.data.attributes.content_type == 'location' &&
                        (<div className="fs-15 no-back-color"><a href={`https://www.google.com/maps/place/${message.replied_message.data.attributes.content_location_latitude},${message.replied_message.data.attributes.content_location_longitude}`} target="_blank">
                          <i className="fas fa-map-marker-alt mr-8"></i>Ver ubicación</a></div>)}
                    {message.replied_message.data.attributes.content_type == 'media' && message.replied_message.data.attributes.content_media_type == 'document' && (
                      <div className="fs-15 no-back-color"><a href="" onClick={(e) => this.downloadFile(e, message.replied_message.data.attributes.content_media_url, message.replied_message.data.attributes.content_media_caption)}><i className="fas fa-file-download mr-8"></i>{message.replied_message.data.attributes.content_media_caption || 'Descargar archivo'}</a></div>
                    )}
                    {message.replied_message.data.attributes.content_type == 'contact' &&
                      message.replied_message.data.attributes.contacts_information.map(contact =>
                        <div className="contact-card w-100 mb-10 no-back-color">
                          <div className="w-100 mb-10"><i className="fas fa-user mr-8"></i>{contact.names.formatted_name}</div>
                          {contact.phones.map(ph =>
                            <div className="w-100 fs-14"><i className="fas fa-phone-square-alt mr-8"></i>{ph.phone}</div>
                          )}
                          {contact.emails.map(em =>
                            <div className="w-100 fs-14"><i className="fas fa-at mr-8"></i>{em.email}</div>
                          )}
                          {contact.addresses.map(addrr =>
                            <div className="w-100 fs-14"><i className="fas fa-map-marker-alt mr-8"></i>{addrr.street ? addrr.street : (addrr.city + ', ' + addrr.state + ', ' + addrr.country)}</div>
                          )}
                          {contact.org && contact.org.company &&
                            <div className="w-100 fs-14"><i className="fas fa-building mr-8"></i>{contact.org.company}</div>
                          }
                        </div>
                      )
                    }
                  </div>
                }
                {message.content_type == 'text' &&
                  <div className="text-pre-line">
                    {message.content_text}
                    <br />
                    <div className="f-right">
                      {this.timeMessage(message)}
                      {message.direction == 'outbound' && this.props.handleMessageEvents === true  &&
                        <i className={ `checks-mark ml-7 fas fa-${
                          message.status === 'sent' ? 'check stroke' : (message.status === 'delivered' ? 'check-double stroke' : ( message.status === 'read' ? 'check-double read' : 'sync'))
                        }`
                        }></i>
                      }
                    </div>
                  </div>
                }
                {message.content_type == 'media' && message.content_media_type == 'image' &&
                    (<div className="img-holder">
                      <img src={message.content_media_url} className="msg__img"
                        onClick={(e) => this.toggleImgModal(e)}/>
                      {message.is_loading && (
                        <div className="lds-dual-ring"></div>
                      )}
                    </div>)}
                {message.content_type == 'media' && (message.content_media_type == 'voice' || message.content_media_type == 'audio') && (
                  <audio controls>
                    <source src={message.content_media_url}/>
                  </audio>
                )}
                {message.content_type == 'media' && message.content_media_type == 'video' && (
                  <video width="320" height="240" controls>
                    <source src={message.content_media_url}/>
                  </video>
                )}
                {message.content_type == 'location' &&
                    (<div className="fs-15"><a href={`https://www.google.com/maps/place/${message.content_location_latitude},${message.content_location_longitude}`} target="_blank">
                      <i className="fas fa-map-marker-alt mr-8"></i>Ver ubicación</a></div>)}
                {message.content_type == 'media' && message.content_media_type == 'document' && (
                  <div className="fs-15"><a href="" onClick={(e) => this.downloadFile(e, message.content_media_url, message.content_media_caption)}><i className="fas fa-file-download mr-8"></i>{message.content_media_caption || 'Descargar archivo'}</a></div>
                )}
                {message.content_media_caption && message.content_media_type !== 'document' &&
                  (<div className="caption text-pre-line">{message.content_media_caption}</div>)}
                {message.content_type == 'contact' &&
                  message.contacts_information.map(contact =>
                    <div className="contact-card w-100 mb-10">
                      <div className="w-100 mb-10"><i className="fas fa-user mr-8"></i>{contact.names.formatted_name}</div>
                      {contact.phones.map(ph =>
                        <div className="w-100 fs-14"><i className="fas fa-phone-square-alt mr-8"></i>{ph.phone}</div>
                      )}
                      {contact.emails.map(em =>
                        <div className="w-100 fs-14"><i className="fas fa-at mr-8"></i>{em.email}</div>
                      )}
                      {contact.addresses.map(addrr =>
                        <div className="w-100 fs-14"><i className="fas fa-map-marker-alt mr-8"></i>{addrr.street ? addrr.street : (addrr.city + ', ' + addrr.state + ', ' + addrr.country)}</div>
                      )}
                      {contact.org && contact.org.company &&
                        <div className="w-100 fs-14"><i className="fas fa-building mr-8"></i>{contact.org.company}</div>
                      }
                    </div>
                  )
                }
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef}></div>
        </div>

        { this.chatAlreadyAssigned() ?
          (
            <div className="col-xs-12">
              <p>Esta conversación ya ha sido asignada a otro usuario.</p>
            </div>
            )
          : (
            this.props.errorSendMessageStatus ?
              (
                <div className="col-xs-12">
                  <p>{this.props.errorSendMessageText}</p>
                </div>
              )
              : (
                this.isChatClosed() ?
                  (
                    <div className="col-xs-12">
                      <p>Este canal de chat se encuentra cerrado. Si lo desea puede enviar una <a href="#" onClick={() => this.openModal() }   >plantilla</a>.</p>
                    </div>
                  ) : (
                    this.canSendMessages() &&
                      <div className="col-xs-12 chat-input">
                        <div className="text-input">
                          <div id="divMessage" contentEditable="true" role="textbox" placeholder-text="Escribe un mensaje aquí" className="message-input fs-14" onPaste={(e) => this.pasteImages(e)} onKeyPress={this.onKeyPress} onKeyUp={this.getCaretPosition} onMouseUp={this.getCaretPosition} tabIndex="0">
                          </div>
                          {this.state.selectedProduct && this.state.selectedProduct.attributes.image &&
                            <div className="selected-product-image-container">
                              <i className="fas fa-times-circle cursor-pointer" onClick={() => this.removeSelectedProduct()}></i>
                              <img src={this.state.selectedProduct.attributes.image} />
                            </div>
                          }
                          {this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url &&
                            <div className="selected-product-image-container">
                              <i className="fas fa-times-circle cursor-pointer" onClick={() => this.removeSelectedFastAnswer()}></i>
                              <img src={this.state.selectedFastAnswer.attributes.image_url} />
                            </div>
                          }
                          <div className="t-right mr-15">
                            {!this.state.recordingAudio &&
                              <div className="p-relative">
                                {this.state.showEmojiPicker &&
                                  <div id="emojis-holder" className="emojis-container">
                                    <Picker
                                      set='apple'
                                      title='Seleccionar...'
                                      emoji='point_up'
                                      onSelect={(emoji) => this.insertEmoji(emoji)}
                                      color='#00B4FF'
                                      i18n={pickerI18n}
                                      skinEmoji='hand'
                                    />
                                  </div>
                                }
                                <input id="attach-file" className="d-none" type="file" name="messageFile" accept="application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document" onChange={(e) => this.handleFileSubmit(e)}/>
                                <div className="tooltip-top">
                                  <i className="fas fa-paperclip fs-22 ml-7 mr-7 cursor-pointer" onClick={() => document.querySelector('#attach-file').click()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Archivos</div>
                                  }
                                </div>
                                <div className="tooltip-top">
                                  <i className="fas fa-image fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.toggleLoadImages()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Imágenes</div>
                                  }
                                </div>
                                <div className="tooltip-top">
                                  <i className="fas fa-bolt fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.toggleFastAnswers()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Respuestas Rápidas</div>
                                  }
                                </div>
                                <div className="tooltip-top">
                                  <i className="fas fa-shopping-bag fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.props.toggleProducts()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Productos</div>
                                  }
                                </div>
                                <div className="tooltip-top">
                                  <i className="fas fa-map-marker-alt fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.getLocation()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Ubicación</div>
                                  }
                                </div>
                                {ENV['INTEGRATION'] == '1' && this.props.allowSendVoice &&
                                  <div className="tooltip-top">
                                    <i className="fas fa-microphone fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.recordAudio()}></i>
                                    {this.props.onMobile == false &&
                                      <div className="tooltiptext">Notas de voz</div>
                                    }
                                  </div>
                                }
                                <div className="tooltip-top">
                                  <i className="fas fa-smile fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.toggleEmojiPicker()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Emojis</div>
                                  }
                                </div>
                                <div className="tooltip-top ml-15"></div>
                                <div className="tooltip-top">
                                  <i className="fas fa-paper-plane fs-22 mr-5 c-secondary cursor-pointer" onClick={(e) => this.handleSubmit(e)}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Enviar</div>
                                  }
                                </div>
                              </div>
                            }
                            {this.state.recordingAudio &&
                              <div className="d-inline-flex ">
                                <div className="tooltip-top cancel-audio-counter">
                                  <i className="far fa-times-circle fs-25 ml-7 mr-7 cursor-pointer" onClick={() => this.cancelAudio()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Cancelar</div>
                                  }
                                </div>
                                <div className="time-audio-counter ml-7 mr-7">
                                  <i className="fas fa-circle fs-15 mr-4"></i>
                                  <span className="c-gray-label">{this.state.audioMinutes}:</span><span className="c-gray-label">{this.state.audioSeconds}</span>
                                </div>
                                <div className="tooltip-top send-audio-counter">
                                  <i className="far fa-check-circle fs-25 ml-7 mr-7 cursor-pointer" onClick={() => this.mediaRecorder.stop()}></i>
                                  {this.props.onMobile == false &&
                                    <div className="tooltiptext">Enviar</div>
                                  }
                                </div>
                              </div>
                            }
                          </div>
                        </div>
                      </div>
                  )
              )
          )
        }

        <Modal isOpen={this.state.isModalOpen} style={customStyles}>
          <div className={this.props.onMobile ? "row mt-50" : "row" }>
            <div className="col-md-10">
              <p className={this.props.onMobile ? "fs-20 mt-0" : "fs-30 mt-0" }>Plantillas</p>
            </div>
            <div className="col-md-2 t-right">
              <button onClick={(e) => this.toggleModal()}>Cerrar</button>
            </div>
          </div>
          { !this.state.isTemplateSelected ?
            (
              <div>
                {this.props.templates.map((template) => (
                  <div className="row" key={template.id}>
                    <div className={this.props.onMobile ? "col-md-10 fs-10" : "col-md-10" }>
                      <p>{template.text}</p>
                    </div>
                    <div className="col-md-2">
                      <button onClick={(e) => this.selectTemplate(template)}>Seleccionar</button>
                    </div>
                  </div>
                ))}
              </div>
              )
            : (
              <div>
                <div className="row">
                  <div className="col-md-12">
                    {screen}
                  </div>
                </div>
                <div className="row mt-30">
                  <div className="col-md-6 t-right">
                    <button onClick={(e) => this.cancelTemplate()}>Cancelar</button>
                  </div>
                  <div className="col-md-6 t-left">
                    <button onClick={(e) => this.sendTemplate()}>Enviar</button>
                  </div>
                </div>
              </div>
            )
          }
        </Modal>

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
  total_pages = state.total_pages || 0;

  return {
    messages: state.messages || [],
    message: state.message || '',
    total_pages: state.total_pages || 0,
    templates: state.templates || [],
    total_template_pages: state.total_template_pages || 0,
    agents: state.agents || [],
    agent_list: state.agent_list || [],
    handleMessageEvents: state.handle_message_events || false,
    recentInboundMessageDate: state.recentInboundMessageDate || null,
    errorSendMessageStatus: state.errorSendMessageStatus,
    errorSendMessageText: state.errorSendMessageText,
    customer: state.customer,
    allowSendVoice: state.allowSendVoice
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
    setNoRead: (customer_id, token) => {
      dispatch(setNoRead(customer_id, token));
    },
    toggleChatBot: (customer_id, token) => {
      dispatch(toggleChatBot(customer_id, token));
    },
    sendWhatsAppBulkFiles: (id, body, token) => {
      dispatch(sendWhatsAppBulkFiles(id, body, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
