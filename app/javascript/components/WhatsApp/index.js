import React, { Component } from "react";
import ChatList from '../shared/ChatList';
import ChatMessages from '../WhatsApp/ChatMessages';
import CustomerDetails from './../shared/CustomerDetails';
import FastAnswers from './../shared/FastAnswers';

class WhatsApp extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null,
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
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null,
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

  setRemovedCustomerInfo = (data) => {
    this.setState({
      removedCustomer: data.remove_only,
      removedCustomerId: data.customer.customer.id,
      newAgentAssignedId: this.state.currentCustomer == data.customer.customer.id ? data.customer.customer.assigned_agent.id : null
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
      <div>
        <div className="box">
          <div className="row">
            {this.state.showChatList && (
              <div className={this.state.onMobile ? "col-xs-12 col-sm-3 chat_list_holder no-border-right" : "col-xs-12 col-sm-3 chat_list_holder" }>
                <ChatList
                  handleOpenChat={this.handleOpenChat}
                  currentCustomer={this.state.currentCustomer}
                  chatType='whatsapp'
                  setRemovedCustomerInfo={this.setRemovedCustomerInfo}
                  storageId={$('meta[name=user_storage]').attr("content")}
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
                  customerDetails={this.state.currentCustomerDetails}
                  removedCustomer={this.state.removedCustomer}
                  removedCustomerId={this.state.removedCustomerId}
                  newAgentAssignedId={this.state.newAgentAssignedId}
                  toggleFastAnswers={this.toggleFastAnswers}
                  fastAnswerText={this.state.fastAnswerText}
                  changeFastAnswerText={this.changeFastAnswerText}
                  onMobile={this.state.onMobile}
                  backToChatList={this.backToChatList}
                  editCustomerDetails={this.editCustomerDetails}
                />
              </div>
            )}

            {this.state.currentCustomer != 0 && this.state.showFastAnswers == false && this.state.showCustomerDetails &&
              <div className="col-xs-12 col-sm-3">
                <CustomerDetails
                  customerDetails={this.state.currentCustomerDetails}
                  chatType='whatsapp_chats'
                  onMobile={this.state.onMobile}
                  backToChatMessages={this.backToChatMessages}
                />
              </div>
            }

            {this.state.currentCustomer != 0 && this.state.showFastAnswers &&
              <div className="col-xs-12 col-sm-3">
                <FastAnswers
                  chatType='whatsapp'
                  changeFastAnswerText={this.changeFastAnswerText}
                  toggleFastAnswers={this.toggleFastAnswers}
                  onMobile={this.state.onMobile}
                />
              </div>
            }
          </div>
        </div>
      </div>
    )
  }
}

export default WhatsApp;
