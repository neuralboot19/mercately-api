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
  setNoRead
} from "../../actions/whatsapp_karix";

import MessageForm from './MessageForm';
import Message from './Message';
import ImagesSelector from './../shared/ImagesSelector';
import GoogleMap from './../shared/Map';

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
      isModalOpen: false,
      url: '',
      agents: [],
      selectedProduct: null,
      showLoadImages: false,
      loadedImages: [],
      selectedFastAnswer: null,
      showMap: false,
      zoomLevel: 17
    };
    this.bottomRef = React.createRef();
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
    let text = { message: message }
    let isText = message && message.trim() !== '';
    this.setState(
      {
        messages: isText ? this.state.messages.concat({text: message, sent_by_retailer: true, created_at: new Date() }) : this.state.messages,
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
    var url, type;

    if (this.state.selectedProduct || this.state.selectedFastAnswer) {
      url = this.state.selectedProduct ? this.state.selectedProduct.attributes.image : this.state.selectedFastAnswer.attributes.image_url;
      type = 'image';

      var data = new FormData();
      data.append('url', url);
      data.append('type', 'image');
    } else {
      url = URL.createObjectURL(el.files[0]);
      type = this.fileType(el.files[0].type);
    }

    this.setState({ messages: this.state.messages.concat({url: url, sent_by_retailer: true, file_type: type, filename: el ? el.files[0].name : null}), new_message: true, selectedProduct: null, selectedFastAnswer: null}, () => {
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
    if(el.scrollTop >= 0 && el.scrollTop <= 5) {
      el.scrollTop = 10;
      this.handleLoadMore();
    }
  }

  findIndexInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  toggleImgModal = (e) => {
    var el = e.target;

    this.setState({
      url: el.src,
      isModalOpen: !this.state.isModalOpen
    });
  }

  componentWillReceiveProps(newProps){
    if (newProps.messages != this.props.messages) {
      this.setState({
        new_message: false,
        messages: newProps.messages.concat(this.state.messages),
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
      el.id == id
    ))
  )

  updateChat = (data) =>{
    var facebook_message = data.facebook_message.facebook_message;
    if (currentCustomer == facebook_message.customer_id) {
      if (!this.state.new_message && facebook_message.sent_from_mercately == false) {
        var index = this.findMessageInArray(this.state.messages, facebook_message.id);

        if (index === -1) {
          this.setState({
            messages: this.state.messages.concat(facebook_message),
            new_message: false,
          })
        } else {
          this.state.messages[index] = facebook_message;
        }
      }

      if (facebook_message.sent_by_retailer == false) {
        this.props.setMessageAsRead(facebook_message.id, csrfToken);
      }

      if (facebook_message.sent_by_retailer == true && facebook_message.date_read) {
        this.state.messages.filter(obj => obj.sent_by_retailer == true)
          .forEach(function(message) {
            if (!message.date_read && moment(message.created_at) <= moment(facebook_message.created_at)) {
              message.date_read = facebook_message.date_read
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
    } else if (file_type.includes('image/') || file_type == 'image') {
      return 'image';
    } else if (['application/pdf', 'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(file_type) ||
      file_type == 'file') {
        return 'file';
    } else if (file_type.includes('audio/') || file_type == 'audio') {
      return 'audio';
    } else if (file_type.includes('video/') || file_type == 'video') {
      return 'video';
    } else if (file_type.includes('location/') || file_type == 'location') {
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
    var classes = message.sent_by_retailer == true ? 'message-by-retailer f-right' : '';
    if (['audio', 'video'].includes(this.fileType(message.file_type)))  classes += 'video-audio';
    return classes;
  }

  handleAgentAssignment = (e) => {
    var value = parseInt(e.target.value);
    var agent = this.props.agent_list.filter(agent => agent.id === value);

    var r = confirm("Estás seguro de asignar este chat a otro agente?");
    if (r == true) {
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

    if (showError || !files || files.length == 0) {
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
    var insertedMessages = [];
    var data = new FormData();
    this.state.loadedImages.map((image) => {
      data.append('file_data[]', image);

      var url = URL.createObjectURL(image);
      var type = this.fileType(image.type);

      insertedMessages.push({url: url, sent_by_retailer: true, file_type: type})
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

  setFocus = () => {
    document.getElementById("divMessage").focus();
  }

  objectPresence = () => {
    if ((this.state.selectedProduct && this.state.selectedProduct.attributes.image) ||
      (this.state.selectedFastAnswer && this.state.selectedFastAnswer.attributes.image_url)) {
        return true;
      }

    return false;
  }

  sendLocation = (position) => {
    let text = {
      message: `https://www.google.com/maps/place/${position.lat},${position.lng}`,
      type: 'location'
    }

    this.setState({ messages: this.state.messages.concat(
      {
        url: text.message,
        sent_by_retailer: true,
        file_type: 'location'
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

  render() {
    return (
      <div className="row bottom-xs">
        {this.props.onMobile && (
          <div className="col-xs-12 row mb-15">
            <div className="col-xs-2 pl-0" onClick={() => this.props.backToChatList()}>
              <i className="fas fa-arrow-left c-secondary fs-30 mt-12"></i>
            </div>
            <div className="col-xs-8 pl-0">
              <div className="profile__name">
                {`${this.props.customerDetails.first_name && this.props.customerDetails.last_name  ? `${this.props.customerDetails.first_name} ${this.props.customerDetails.last_name}` : this.props.customerDetails.phone}`}
              </div>
              <div className={this.props.customerDetails["unread_message?"] ? 'fw-bold' : ''}>
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
            <div className='assigned-to'>
              <small>Asignado a: </small>
              <select id="agents" value={this.props.newAgentAssignedId || this.props.customerDetails.assigned_agent.id || ''} onChange={(e) => this.handleAgentAssignment(e)}>
                <option value="">No asignado</option>
                {this.props.agent_list.map((agent, index) => (
                  <option value={agent.id} key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
                ))}
              </select>
            </div>
            <div className='mark-no-read'>
              <button onClick={(e) => this.setNoRead(e)} className='btn btn--cta btn-small right'>Marcar como no leído</button>
            </div>
          </div>
          )}
        {this.state.isModalOpen && (
          <div className="img_modal">
            <div className="img_modal__overlay" onClick={(e) => this.toggleImgModal(e)}>
            </div>
            <img src={this.state.url} />
          </div>
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)}>
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
              <div className={ this.divClasses(message) }>
                <Message message={message} toggleImgModal={this.toggleImgModal} downloadFile={this.downloadFile} fileType={this.fileType}/>
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
            <div className="col-xs-12 chat-input">
              <MessageForm
                currentCustomer={this.props.currentCustomer}
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
              />
            </div>
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
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
