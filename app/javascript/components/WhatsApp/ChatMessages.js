import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { sendWhatsAppMessage, fetchWhatsAppMessages, sendWhatsAppImg, setWhatsAppMessageAsReaded, fetchWhatsAppTemplates } from "../../actions/whatsapp_karix";
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
      auxTemplateSelected: []
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

    var rDate = moment(this.props.recentInboundMessageDate);
    this.state.can_write = moment().diff(rDate, 'hours') < 24;
    this.setState({ messages: [],  page: 1, scrolable: true}, () => {
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
          var index = this.findMessageInArray(messages, karix_message.id);
          messages = this.removeByTextArray(messages, karix_message.content_text);

          if (index === -1) {
            this.setState({
              messages: this.state.messages.concat(karix_message),
              new_message: false,
            })
          }
        }
      } else if ((['image', 'voice', 'audio', 'video'].includes(karix_message.content_media_type) || karix_message.content_type == 'location') &&
        karix_message.direction === 'inbound') {
        this.setState({
          messages: this.state.messages.concat(karix_message),
          new_message: false,
        })
      }

      if (karix_message.direction === 'inbound') {
        this.props.setWhatsAppMessageAsReaded(currentCustomer, {message_id: karix_message.id}, csrfToken);
        this.state.can_write = true;
      }
    }
  }

  componentWillReceiveProps(newProps){
    if (newProps.messages != this.props.messages) {
      this.setState({
        new_message: false,
        messages: newProps.messages.concat(this.state.messages),
        load_more: false,
      })
    }
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
      total_pages = 0;
      var rDate = moment(this.props.recentInboundMessageDate);
      this.state.can_write = moment().diff(rDate, 'hours') < 24;
      this.scrollToBottom();
      this.setState({ messages: [],  page: 1, scrolable: true}, () => {
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
    this.setState({ messageText: '' }, () => {
      this.handleSubmitWhatsAppMessage(e, text)
    });
  }

  handleSubmitWhatsAppMessage = (e, message) => {
    if (e) {
      e.preventDefault();
    }

    let text = { message: message, customer_id: this.props.currentCustomer}
    this.setState({ messages: this.state.messages.concat({content_type: 'text', content_text: message, direction: 'outbound'}), new_message: true}, () => {
      this.props.sendWhatsAppMessage(text, csrfToken);
      this.scrollToBottom();
    });
  }

  findMessageInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  removeByTextArray = (arr, text) => {
    var index = arr.findIndex((el) => (
      el.content_text === text && !el.id
    ))

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
    this.handleSubmitImg(el, data);
  }

  handleSubmitImg = (el, file_data) => {
    var url = URL.createObjectURL(el.files[0]);
    this.setState({ messages: this.state.messages.concat({content_type: 'media', content_media_type: 'image', content_media_url: url, direction: 'outbound'}), new_message: true}, () => {
      this.props.sendWhatsAppImg(this.props.currentCustomer, file_data, csrfToken);
      this.scrollToBottom();
    });
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
        return <input value='' onChange={ (e) => this.changeTemplateSelected(e, index)}   /> ;
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

      this.handleSubmitWhatsAppMessage(null, message);
      this.cancelTemplate();
    } else {
      alert('Debe llenar todos los campos editables');
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
        {this.state.isImgModalOpen && (
          <div className="img_modal">
            <div className="img_modal__overlay" onClick={(e) => this.toggleImgModal(e)}>
            </div>
            <img src={this.state.url} />
          </div>
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)}>
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
              <div className={ message.direction == 'outbound' ? 'message-by-retailer f-right' : '' } >
                {message.content_type == 'text' &&
                    (<p>{message.content_text}</p>)}
                {message.content_type == 'media' && message.content_media_type == 'image' &&
                    (<div className="img-holder">
                      <img src={message.content_media_url} className="msg__img"
                        onClick={(e) => this.toggleImgModal(e)}/>
                      {message.is_loading && (
                        <div class="lds-dual-ring"></div>
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
                {message.content_media_caption &&
                  (<p>{message.content_media_caption}</p>)}
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef}></div>
        </div>

        { this.props.currentCustomer != 0 && this.state.can_write &&
          <div className="col-xs-12">
            <div className="text-input">
              <textarea name="messageText" placeholder="Mensaje" autoFocus value={this.state.messageText} onChange={this.handleInputChange} onKeyPress={this.onKeyPress}></textarea>
              <input id="attach" className="d-none" type="file" name="messageImg" accept="image/jpg, image/jpeg, image/png" onChange={(e) => this.handleImgSubmit(e)}/>
              <i className="fas fa-camera fs-24 cursor-pointer" onClick={() => document.querySelector('#attach').click()}></i>
            </div>
          </div>
        }

        { this.props.currentCustomer != 0 && !this.state.can_write &&
          <div className="col-xs-12">
            <p>Este canal de chat se encuentra cerrado. Si lo desea puede enviar una <a href="#" onClick={(e) => this.toggleModal() }   >plantilla</a>.</p>
          </div>
        }

        <Modal isOpen={this.state.isModalOpen} style={customStyles}>
          <div className="row">
            <div className="col-md-10">
              <p className="fs-30 mt-0">Plantillas</p>
            </div>
            <div className="col-md-2 t-right">
              <button onClick={(e) => this.toggleModal()}>Cerrar</button>
            </div>
          </div>
          { !this.state.isTemplateSelected ? 
            (
              <div>
                {this.props.templates.map((template) => (
                  <div className="row">
                    <div className="col-md-10">
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
    setWhatsAppMessageAsReaded: (id, body, token) => {
      dispatch(setWhatsAppMessageAsReaded(id, body, token));
    },
    fetchWhatsAppTemplates: (page = 1, token) => {
      dispatch(fetchWhatsAppTemplates(page, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
