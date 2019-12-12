import React, { Component } from "react";

import ChatMessages from '../chat/ChatMessages';
import ChatList from '../chat/ChatList';
import CustomerDetails from '../chat/CustomerDetails';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
    };
  }

  handleOpenChat = (customer_details) => {
    this.setState({
      ...this.state,
      currentCustomer: customer_details.id,
      currentCustomerDetails: customer_details
    });
  }

  render() {
    var screen;
    if (this.state.currentCustomer === 0) {
      screen = <div className="col-sm-9">
        Selecciona un chat
      </div>
    } else {
      screen = <>
        <div className="col-sm-6">
          <ChatMessages
            currentCustomer={this.state.currentCustomer}
          />
        </div>
        <div className="col-sm-3">
          <CustomerDetails
            customerDetails={this.state.currentCustomerDetails}
          />
        </div>
      </>
    }
    return (
      <div className="box">
        <div className="row">
          <div className="col-sm-3 chat_list_holder">
            <ChatList
              handleOpenChat={this.handleOpenChat}
              currentCustomer={this.state.currentCustomer}
            />
          </div>
          {screen}
        </div>
      </div>
    )
  }
}

export default Chat;
