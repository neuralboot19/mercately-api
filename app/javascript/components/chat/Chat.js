import React, { Component } from "react";

import ChatMessages from '../chat/ChatMessages';
import ChatList from '../shared/ChatList';
import CustomerDetails from './../shared/CustomerDetails';
import FastAnswers from './../shared/FastAnswers';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      showFastAnswers: false,
      fastAnswerText: null
    };
  }

  handleOpenChat = (customer_details) => {
    customer_details["unread_message?"] = false;
    this.setState({
      ...this.state,
      currentCustomer: customer_details.id,
      currentCustomerDetails: customer_details,
      showFastAnswers: false
    });
  }

  toggleFastAnswers = () => {
    this.setState({
      showFastAnswers: !this.state.showFastAnswers
    })
  }

  changeFastAnswerText = (text) => {
    this.setState({
      fastAnswerText: text
    })
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
            toggleFastAnswers={this.toggleFastAnswers}
            fastAnswerText={this.state.fastAnswerText}
            changeFastAnswerText={this.changeFastAnswerText}
          />
        </div>

        {this.state.showFastAnswers == false &&
          <div className="col-sm-3">
            <CustomerDetails
              customerDetails={this.state.currentCustomerDetails}
              chatType='facebook_chats'
            />
          </div>
        }

        {this.state.showFastAnswers &&
          <div className="col-sm-3">
            <FastAnswers
              chatType='facebook'
              changeFastAnswerText={this.changeFastAnswerText}
              toggleFastAnswers={this.toggleFastAnswers}
            />
          </div>
        }
      </>
    }
    return (
      <div className="box">
        <div className="row">
          <div className="col-sm-3 chat_list_holder">
            <ChatList
              handleOpenChat={this.handleOpenChat}
              currentCustomer={this.state.currentCustomer}
              chatType="facebook"
            />
          </div>
          {screen}
        </div>
      </div>
    )
  }
}

export default Chat;
