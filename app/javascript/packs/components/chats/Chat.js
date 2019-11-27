import React, { Component } from "react";

import ChatMessages from './ChatMessages';
import ChatList from './ChatList';
import CustomerDetails from './CustomerDetails';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0
    };
  }

  handleOpenChat = (id) => {
    this.setState({
      ...this.state,
      currentCustomer: id
    })
  }

  render() {
    return (
      <div className="box">
        <div className="row">
          <div className="col-sm-3">
            <ChatList
              handleOpenChat={this.handleOpenChat}
            />
          </div>
          <div className="col-sm-6">
            <ChatMessages
              currentCustomer={this.state.currentCustomer}
            />
          </div>
          <div className="col-sm-3">
            <CustomerDetails
              currentCustomer={this.state.currentCustomer}
            />
          </div>
        </div>
      </div>
    )
  }
}

export default Chat;
