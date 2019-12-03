import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages } from "../../actions/actions";
import { ActionCableProvider } from 'react-actioncable-provider';

import ChatMessage from './ChatMessage';
import Cable from '../../Cable.js';

var currentCustomer = 0;
class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  handleReceivedMessage = () => {
    console.log('received msg');
  }

  componentDidUpdate() {
    console.log('did update');
    let id = this.props.currentCustomer;
    if (currentCustomer !== id) {
      console.log('did update fetch messages');
      currentCustomer = id
      this.props.fetchMessages(id);
      App.cable.subscriptions.create(
        { channel: 'FacebookMessagesChannel', id: currentCustomer },
        {
          received: data => {
            console.log('FacebookMessagesChannel');
            console.log(data);
            this.props.fetchMessages(id);
          }
        }
      );
    }
  }

  render() {
    var messages = this.props.messages;
    return (
      <div>
        {messages.map((message) => (
          <ChatMessage key={message.id} message={message}/>
        ))}
      </div>
    )
  }
}


function mapStateToProps(state) {
  return {
    messages: state.messages || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id) => {
      dispatch(fetchMessages(id));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
