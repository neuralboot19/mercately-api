import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import {
  sendWhatsAppMessage,
  fetchWhatsAppMessages,
  sendWhatsAppImg,
  setWhatsAppMessageAsRead,
  fetchWhatsAppTemplates,
  changeCustomerAgent } from "../../actions/whatsapp_karix";
import Modal from 'react-modal';

var currentCustomer = 0;
var total_pages = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content

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
      messageText: '',
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
      updated: true
    };
    this.bottomRef = React.createRef();
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
    currentCustomer = id;

    this.setState({
      messages: [],
      page: 1,
      scrolable: true
    }, () => {
      this.props.fetchWhatsAppMessages(id);
      this.scrollToBottom();
    });

    this.props.fetchWhatsAppTemplates(this.templatePage, csrfToken);
    socket.on("message_chat", data => this.updateChat(data));
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
              messages: this.state.messages.concat(karix_message).sort((a, b) => (a.id > b.id) ? 1 : -1),
              new_message: false,
              updated: false
            }, () => this.setState({ updated: true}))
          }
        }
      } else if ((['image', 'voice', 'audio', 'video', 'document'].includes(karix_message.content_media_type) || karix_message.content_type == 'location') &&
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

  componentWillReceiveProps(newProps){
    if (newProps.messages != this.props.messages && newProps.updated == this.props.updated) {
      var rDate = moment(newProps.recentInboundMessageDate).local();
      this.setState({
        new_message: false,
        messages: newProps.messages.concat(this.state.messages),
        load_more: false,
        can_write: moment().local().diff(rDate, 'hours') < 24
      })
    }

    if (newProps.fastAnswerText) {
      this.state.messageText = newProps.fastAnswerText;
      this.props.changeFastAnswerText(null);
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
      this.setState({
        messages: [],
        page: 1,
        scrolable: true
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
    let text = this.state.messageText;
    if(text.trim() === '') return;
    var rDate = moment(this.props.recentInboundMessageDate).local();
    this.setState({
      can_write: moment().local().diff(rDate, 'hours') < 24
    }, () => {
      if (this.state.can_write) {
        this.setState({ messageText: '' }, () => {
          this.handleSubmitWhatsAppMessage(e, text, false)
        });
      }
    })
  }

  handleSubmitWhatsAppMessage = (e, message, isTemplate) => {
    if (e) {
      e.preventDefault();
    }

    let text = { message: message, customer_id: this.props.currentCustomer, template: isTemplate }
    this.setState({ messages: this.state.messages.concat({
      content_type: 'text',
      content_text: message,
      direction: 'outbound',
      status: 'enqueued'
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

  handleImgSubmit = (e) => {
    var el = e.target;
    var file = el.files[0];
    if(!file.type.includes('image/jpg') && !file.type.includes('image/jpeg') && !file.type.includes('image/png')) {
      alert('Error: El archivo debe ser una imagen JPG/JPEG o PNG');
      return;
    }

    // Max 8 Mb allowed
    if(file.size > 8*1024*1024) {
      alert('Error: Maximo permitido 8MB');
      return;
    }

    var data = new FormData();
    data.append('file_data', file);
    data.append('template', false);
    this.handleSubmitImg(el, data);
  }

  handleSubmitImg = (el, file_data) => {
    var url = URL.createObjectURL(el.files[0]);
    var type = this.fileType(el.files[0].type);
    var caption = type == 'document' ? el.files[0].name : null;
    this.setState({ messages: this.state.messages.concat({content_type: 'media', content_media_type: type, content_media_url: url, direction: 'outbound', content_media_caption: caption}), new_message: true}, () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, file_data, csrfToken);
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
      var message = this.state.auxTemplateSelected.join('');

      this.handleSubmitWhatsAppMessage(null, message, true);
      this.cancelTemplate();
    } else {
      alert('Debe llenar todos los campos editables');
    }
  }

  handleAgentAssignment = () => {
    var value = parseInt($('#agents').val());
    var agent = this.props.agents.filter(agent => agent.id === value);

    var r = confirm("Estás seguro de asignar este chat a otro agente?");
    if (r == true) {
      var params = {
        agent: {
          retailer_user_id: agent[0] ? agent[0].id : null
        }
      };

      this.props.customerDetails.assigned_agent.id = value;
      this.props.changeCustomerAgent(this.props.currentCustomer, params, csrfToken);
    }
  }

  toggleFastAnswers = () => {
    this.props.toggleFastAnswers();
  }

  divClasses = (message) => {
    var classes = message.direction == 'outbound' ? 'message-by-retailer f-right' : '';
    if (['voice', 'audio', 'video'].includes(this.fileType(message.content_media_type)))  classes += 'video-audio';
    return classes;
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
        { this.props.currentCustomer != 0 && (!this.props.removedCustomer || (this.props.removedCustomer && this.props.currentCustomer !== this.props.removedCustomerId)) &&
          (<div className="top-chat-bar pl-10">
            <small>Asignado a:</small>&nbsp;&nbsp;
            <select id="agents" value={this.props.newAgentAssignedId || this.props.customerDetails.assigned_agent.id || ''} onChange={() => this.handleAgentAssignment()}>
              <option value="">No asignado</option>
              {this.props.agents.map((agent, index) => (
                <option value={agent.id} key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
              ))}
            </select>
          </div>
          )}
        {this.state.isImgModalOpen && (
          <div className="img_modal">
            <div className="img_modal__overlay" onClick={(e) => this.toggleImgModal(e)}>
            </div>
            <img src={this.state.url} />
          </div>
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)}>
          {this.state.messages.map((message, index) => (
            <div key={index} className="message">
              <div className={ this.divClasses(message) } >
                {message.content_type == 'text' &&
                  <p className={message.status === 'read' && this.props.handleMessageEvents === true  ? 'read-message' : ''}>{message.content_text} {
                    message.direction == 'outbound' && this.props.handleMessageEvents === true  &&
                      <i className={ `fas fa-${
                        message.status === 'sent' ? 'check stroke' : (message.status === 'delivered' ? 'check-double stroke' : ( message.status === 'read' ? 'check-double' : 'sync'))
                      }`
                      }></i>
                  }</p>
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
                    (<p className="fs-15"><a href={`https://www.google.com/maps/place/${message.content_location_latitude},${message.content_location_longitude}`} target="_blank">
                      <i className="fas fa-globe-europe mr-8"></i>Ver ubicación</a></p>)}
                {message.content_type == 'media' && message.content_media_type == 'document' && (
                  <p className="fs-15"><a href="" onClick={(e) => this.downloadFile(e, message.content_media_url, message.content_media_caption)}><i className="fas fa-file-download mr-8"></i>{message.content_media_caption || 'Descargar archivo'}</a></p>
                )}
                {message.content_media_caption && message.content_media_type !== 'document' &&
                  (<p>{message.content_media_caption}</p>)}
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef}></div>
        </div>

        { this.props.currentCustomer != 0 && this.props.removedCustomer && this.props.currentCustomer == this.props.removedCustomerId ?
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
                this.props.currentCustomer != 0 && !this.state.can_write && (!this.props.removedCustomer || (this.props.removedCustomer && this.props.currentCustomer !== this.props.removedCustomerId)) ?
                  (
                    <div className="col-xs-12">
                      <p>Este canal de chat se encuentra cerrado. Si lo desea puede enviar una <a href="#" onClick={(e) => this.toggleModal() }   >plantilla</a>.</p>
                    </div>
                  ) : (
                    this.props.currentCustomer != 0 && this.state.can_write && (!this.props.removedCustomer || (this.props.removedCustomer && this.props.currentCustomer !== this.props.removedCustomerId)) &&
                      <div className="col-xs-12">
                        <div className="text-input">
                          <textarea name="messageText" placeholder="Mensajes" autoFocus value={this.state.messageText} onChange={this.handleInputChange} onKeyPress={this.onKeyPress}></textarea>
                          <input id="attach" className="d-none" type="file" name="messageImg" accept="image/jpg, image/jpeg, image/png" onChange={(e) => this.handleImgSubmit(e)}/>
                          <i className="fas fa-camera fs-24 cursor-pointer" onClick={() => document.querySelector('#attach').click()}></i>
                          <input id="attach-file" className="d-none" type="file" name="messageFile" accept="application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document" onChange={(e) => this.handleFileSubmit(e)}/>
                          <i className="fas fa-file-alt fs-24 ml-5 cursor-pointer" onClick={() => document.querySelector('#attach-file').click()}></i>
                          <i className="fas fa-paper-plane fs-22 ml-5 cursor-pointer" onClick={() => this.toggleFastAnswers()}></i>
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
    handleMessageEvents: state.handle_message_events || false,
    recentInboundMessageDate: state.recentInboundMessageDate || null,
    errorSendMessageStatus: state.errorSendMessageStatus,
    errorSendMessageText: state.errorSendMessageText
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
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
