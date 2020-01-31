import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages, sendMessage, sendImg, setMessageAsReaded } from "../../actions/actions";

import MessageForm from './MessageForm';
import ImgModal from './ImgModal';
import ChatMessage from './ChatMessage';

var currentCustomer = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content
var channelSubscription;

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
      url: ''
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
    this.setState({ messages: this.state.messages.concat({text: message, sent_by_retailer: true}), new_message: true}, () => {
      this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
      this.scrollToBottom();
    });
  }

  handleSubmitImg = (el, file_data) => {
    var url = URL.createObjectURL(el.files[0]);
    this.setState({ messages: this.state.messages.concat({url: url, sent_by_retailer: true}), new_message: true}, () => {
      this.props.sendImg(this.props.currentCustomer, file_data, csrfToken);
      this.scrollToBottom();
    });
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

  handleChannelSubscription = () => (
    App.cable.subscriptions.create(
      { channel: 'FacebookMessagesChannel', id: currentCustomer },
      {
        received: data => {
          var facebook_message = data.facebook_message;
          if (currentCustomer == facebook_message.customer_id) {
            if (!this.state.new_message) {
              this.setState({
                messages: this.state.messages.concat(facebook_message),
                new_message: false,
              })
            }
            this.props.setMessageAsReaded(facebook_message.id, csrfToken);
          }
        }
      }
    )
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
  }

  componentDidMount() {
    let id = this.props.currentCustomer;
    currentCustomer = id;

    this.setState({ messages: [],  page: 1, scrolable: true}, () => {
      channelSubscription = this.handleChannelSubscription();
      this.props.fetchMessages(id);
      this.scrollToBottom();
    });
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
      this.setState({ messages: [],  page: 1, scrolable: true}, () => {
        channelSubscription.unsubscribe();
        channelSubscription = this.handleChannelSubscription();
        this.props.fetchMessages(id);
      });
    }

    if (this.state.scrolable) {
      this.scrollToBottom();
    }
  }

  render() {
    return (
      <div className="row bottom-xs">
        {this.state.isModalOpen && (
          <ImgModal url={this.state.url} toggleImgModal={this.toggleImgModal}/>
        )}
        <div className="col-xs-12 chat__box pt-8" onScroll={(e) => this.handleScrollToTop(e)}>
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
              <div className={ message.sent_by_retailer == true ? 'message-by-retailer f-right' : '' }>
                <ChatMessage message={message}/>
              </div>
            </div>
          ))}
          <div id="bottomRef" ref={this.bottomRef}></div>
        </div>

        { currentCustomer != 0 &&
        <div className="col-xs-12">
          <MessageForm
            currentCustomer={this.props.currentCustomer}
            handleSubmitMessage={this.handleSubmitMessage}
            handleSubmitImg={this.handleSubmitImg}
          />
        </div>
        }
      </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    messages: state.messages || [],
    message: state.message || [],
    total_pages: state.total_pages || 0,
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
    setMessageAsReaded: (id, token) => {
      dispatch(setMessageAsReaded(id, token))
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
