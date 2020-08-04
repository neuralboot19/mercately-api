import React, { Component } from "react";

import ChatMessages from '../chat/ChatMessages';
import ChatList from '../shared/ChatList';
import CustomerDetails from './../shared/CustomerDetails';
import FastAnswers from './../shared/FastAnswers';
import Products from './../shared/Products';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      showFastAnswers: false,
      showChatList: true,
      showChatMessagesSelect: true,
      showChatMessages: true,
      showCustomerDetails: true,
      onMobile: false,
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null,
      showProducts: false,
      selectedProduct: null,
      selectedFastAnswer: null
    };
  }

  handleOpenChat = (customer_details) => {
    customer_details["unread_message?"] = false;
    this.setState({
      ...this.state,
      currentCustomer: customer_details.id,
      currentCustomerDetails: customer_details,
      showFastAnswers: false,
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null,
      showProducts: false
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
      showFastAnswers: !this.state.showFastAnswers,
      showProducts: false
    })

    if (this.state.onMobile) {
      this.setState({
        showChatMessages: !this.state.showChatMessages,
        showCustomerDetails: false,
        showProducts: false
      })
    }
  }

  changeFastAnswer = (answer) => {
    this.setState({
      selectedFastAnswer: answer,
      selectedProduct: null
    })

    if (this.state.onMobile) {
      this.setState({
        showFastAnswers: false,
        showChatMessages: true
      })
    }
  }

  toggleProducts = () => {
    this.setState({
      showProducts: !this.state.showProducts,
      showFastAnswers: false
    })

    if (this.state.onMobile) {
      this.setState({
        showChatMessages: !this.state.showChatMessages,
        showCustomerDetails: false,
        showFastAnswers: false
      })
    }
  }

  selectProduct = (product) => {
    this.setState({
      selectedProduct: product,
      selectedFastAnswer: null
    })

    if (this.state.onMobile) {
      this.setState({
        showProducts: false,
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
        showProducts: false,
        onMobile: true
      })
    }
  }

  setRemovedCustomerInfo = (data) => {
    this.setState({
      removedCustomer: data.remove_only,
      removedCustomerId: data.customer.customer.id,
      newAgentAssignedId: this.state.currentCustomer == data.customer.customer.id ? data.customer.customer.assigned_agent.id : null
    })
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
                toggleFastAnswers={this.toggleFastAnswers}
                selectedFastAnswer={this.state.selectedFastAnswer}
                changeFastAnswer={this.changeFastAnswer}
                onMobile={this.state.onMobile}
                backToChatList={this.backToChatList}
                editCustomerDetails={this.editCustomerDetails}
                customerDetails={this.state.currentCustomerDetails}
                removedCustomer={this.state.removedCustomer}
                removedCustomerId={this.state.removedCustomerId}
                newAgentAssignedId={this.state.newAgentAssignedId}
                toggleProducts={this.toggleProducts}
                selectProduct={this.selectProduct}
                selectedProduct={this.state.selectedProduct}
              />
            </div>
          )}

          {this.state.currentCustomer != 0 && this.state.showFastAnswers == false && this.state.showProducts == false && this.state.showCustomerDetails &&
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
                changeFastAnswer={this.changeFastAnswer}
                toggleFastAnswers={this.toggleFastAnswers}
                onMobile={this.state.onMobile}
              />
            </div>
          }

          {this.state.currentCustomer != 0 && this.state.showProducts &&
            <div className="col-xs-12 col-sm-3">
              <Products
                toggleProducts={this.toggleProducts}
                onMobile={this.state.onMobile}
                selectProduct={this.selectProduct}
              />
            </div>
          }
        </div>
      </div>
    )
  }
}

export default Chat;
