import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages, sendMessage } from "../../actions/actions";

import MessageForm from './MessageForm';

var currentCustomer = 0;
var shouldScrollToBottom = true;
const csrfToken = document.querySelector('[name=csrf-token]').content

class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
      load_more: false,
      page: 1,
      messages: [],
      new_message: false,
    };
    this.bottomRef = React.createRef();
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.setState({ page: this.state.page += 1,  load_more: true})
    shouldScrollToBottom = false;
  }

  componentWillReceiveProps(newProps){
    if (newProps.messages != this.props.messages) {
      this.setState({
        new_message: false,
        messages: newProps.messages.concat(this.state.messages)
      })
    }
  }

  handleSubmitMessage = (e, message) => {
    e.preventDefault();
    let text = { message: message }
    this.setState({ messages: this.state.messages.concat({text: message}), new_message: true}, () => {
      this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
    });
  }

  scrollToBottom = () => {
    this.bottomRef.current.scrollIntoView({ behavior: "smooth" });
  }

  componentDidUpdate() {
    if (shouldScrollToBottom) this.scrollToBottom();
    let id = this.props.currentCustomer;
    if (currentCustomer !== id) {
      shouldScrollToBottom = true;
      currentCustomer = id

      this.setState({ messages: [],  page: 1}, () => {
        this.props.fetchMessages(id);
      });

      App.cable.subscriptions.create(
        { channel: 'FacebookMessagesChannel', id: currentCustomer },
        {
          received: data => {
            if (!this.state.new_message){
              this.setState({
                messages: this.state.messages.concat(data.facebook_message),
                new_message: false,
              })
            }
          }
        }
      );
    } else if (this.state.load_more === true) {
      this.setState({ load_more: false }, () => {
        this.props.fetchMessages(id, this.state.page);
      });
    }
  }

  render() {
    var loadMore;
    if (this.props.total_pages > this.state.page) {
      loadMore = <a href="" onClick={(e) => this.handleLoadMore(e)}>Load more</a>
    }
    return (
      <div className="row bottom-xs">
        <div className="col-xs-12 chat__box pt-8">
          {loadMore}
          {this.state.messages.map((message) => (
            <div key={message.id} className="message">
              <div className={ message.sent_by_retailer == true ? 'message-by-retailer f-right' : '' }>
                <p>{message.text}</p>
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
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
