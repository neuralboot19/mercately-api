import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages } from "../../actions/actions";

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
    }
  }

  render() {
    var messages = this.props.messages;
    return (
      <div>
        <Cable
          currentCustomer={this.props.currentCustomer}
          handleReceivedMessage={this.handleReceivedMessage}
        />
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
