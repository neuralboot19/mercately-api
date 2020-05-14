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
      fastAnswerText: null,
      showChatList: true,
      showChatMessagesSelect: true,
      showChatMessages: true,
      showCustomerDetails: true,
      onMobile: false
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

    if (this.state.onMobile) {
      this.setState({
        showChatList: false,
        showChatMessages: true
      })
    }
  }

  getScreenWidth = () => {
    return window.innerWidth;
  }

  backToChatList = () => {
    this.setState({
      showChatList: true,
      showChatMessages: false
    })
  }

  backToChatMessages = () => {
    this.setState({
      showChatMessages: true,
      showCustomerDetails: false
    })
  }

  editCustomerDetails = () => {
    this.setState({
      showChatMessages: false,
      showCustomerDetails: true
    })
  }

  toggleFastAnswers = () => {
    this.setState({
      showFastAnswers: !this.state.showFastAnswers
    })

    if (this.state.onMobile) {
      this.setState({
        showChatMessages: !this.state.showChatMessages,
        showCustomerDetails: false
      })
    }
  }

  changeFastAnswerText = (text) => {
    this.setState({
      fastAnswerText: text
    })

    if (this.state.onMobile) {
      this.setState({
        showFastAnswers: false,
        showChatMessages: true
      })
    }
  }

  componentDidMount() {
    var screenWidth = this.getScreenWidth();

    if (screenWidth <= 767) {
      this.setState({
        showChatList: true,
        showChatMessagesSelect: false,
        showChatMessages: false,
        showCustomerDetails: false,
        showFastAnswers: false,
        onMobile: true
      })
    }
  }

  render() {
    return (
      <div className="box">
        <div className="row">
          {this.state.showChatList && (
            <div className={this.state.onMobile ? "col-xs-12 col-sm-3 chat_list_holder no-border-right" : "col-xs-12 col-sm-3 chat_list_holder" }>
              <ChatList
                handleOpenChat={this.handleOpenChat}
                currentCustomer={this.state.currentCustomer}
                chatType="facebook"
              />
            </div>
          )}

          {this.state.currentCustomer === 0 && this.state.showChatMessagesSelect && (
            <div className="col-xs-12 col-sm-9">
              Selecciona un chat
            </div>
          )}

          {this.state.currentCustomer != 0 && this.state.showChatMessages && (
            <div className="col-xs-12 col-sm-6">
              <ChatMessages
                currentCustomer={this.state.currentCustomer}
                toggleFastAnswers={this.toggleFastAnswers}
                fastAnswerText={this.state.fastAnswerText}
                changeFastAnswerText={this.changeFastAnswerText}
                onMobile={this.state.onMobile}
                backToChatList={this.backToChatList}
                editCustomerDetails={this.editCustomerDetails}
                customerDetails={this.state.currentCustomerDetails}
              />
            </div>
          )}

          {this.state.currentCustomer != 0 && this.state.showFastAnswers == false && this.state.showCustomerDetails &&
            <div className="col-xs-12 col-sm-3">
              <CustomerDetails
                customerDetails={this.state.currentCustomerDetails}
                chatType='facebook_chats'
                onMobile={this.state.onMobile}
                backToChatMessages={this.backToChatMessages}
              />
            </div>
          }

          {this.state.currentCustomer != 0 && this.state.showFastAnswers &&
            <div className="col-xs-12 col-sm-3">
              <FastAnswers
                chatType='facebook'
                changeFastAnswerText={this.changeFastAnswerText}
                toggleFastAnswers={this.toggleFastAnswers}
                onMobile={this.state.onMobile}
              />
            </div>
          }
        </div>
      </div>
    )
  }
}

export default Chat;
