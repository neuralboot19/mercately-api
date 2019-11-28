import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages } from "../../actions/actions";

import ChatMessage from './ChatMessage';

var currentCustomer = 0;
class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  componentDidUpdate() {
    let id = this.props.currentCustomer;
    if (currentCustomer !== id) {
      currentCustomer = id
      this.props.fetchMessages(id);
    }
  }

  render() {
    return (
      <div>
        {this.props.messages.map((message) => (
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
