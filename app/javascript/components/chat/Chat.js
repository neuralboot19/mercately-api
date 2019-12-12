import React, { Component } from "react";
import { BrowserRouter as Router, Route, browserHistory, withRouter } from 'react-router-dom';

import ChatMessages from '../chat/ChatMessages';
import ChatList from '../chat/ChatList';
import CustomerDetails from '../chat/CustomerDetails';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      currentRetailer: 'pruebasasd'
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
    return (
      <div className="box">
        <div className="row">
          <div className="col-sm-3 chat_list_holder">
            <ChatList
              handleOpenChat={this.handleOpenChat}
              currentCustomer={this.state.currentCustomer}
            />
          </div>
          <div className="col-sm-6">
            <ChatMessages
              currentCustomer={this.state.currentCustomer}
            />
          </div>
          <div className="col-sm-3">
            <CustomerDetails
              customerDetails={this.state.currentCustomerDetails}
              currentRetailer={this.state.currentRetailer}
            />
          </div>
        </div>
      </div>
    )
  }
}

export default withRouter(Chat);
