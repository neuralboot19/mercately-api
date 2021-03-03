import React, { Component } from "react";
import ChatMessages from '../chat/ChatMessages';
import ChatSideBar from '../shared/ChatSideBar';
import CustomerDetails from './../shared/CustomerDetails';
import FastAnswers from './../shared/FastAnswers';
import Products from './../shared/Products';
import SelectChatLabel from '../shared/SelectChatLabel';

class Chat extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null,
      showFastAnswers: false,
      showChatList: true,
      showChatMessagesSelect: true,
      showChatMessages: true,
      showCustomerDetails: true,
      onMobile: false,
      showProducts: false,
      selectedProduct: null,
      selectedFastAnswer: null
    };
  }

  handleOpenChat = (customerDetails) => {
    // eslint-disable-next-line no-param-reassign
    customerDetails["unread_message?"] = false;
    this.setState((prevState) => {
      const newState = {
        ...prevState,
        currentCustomer: customerDetails.id,
        currentCustomerDetails: customerDetails,
        removedCustomer: null,
        removedCustomerId: null,
        newAgentAssignedId: null,
        showFastAnswers: false,
        showProducts: false
      };
      if (prevState.onMobile) {
        newState.showChatList = false;
        newState.showChatMessages = true;
      }
      return newState;
    });
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
      newAgentAssignedId: this.state.currentCustomer === data.customer.customer.id ? data.customer.customer.assigned_agent.id : null
    })
  }

  render() {
    return (
      <div>
        <div className="box">
          <div className="row">
            {this.state.showChatList && (
              <div className={this.state.onMobile ? "col-xs-12 col-sm-3 chat_list_holder no-border-right" : "col-xs-12 col-sm-3 chat_list_holder" }>
                <ChatSideBar
                  handleOpenChat={this.handleOpenChat}
                  currentCustomer={this.state.currentCustomer}
                  chatType="facebook"
                  setRemovedCustomerInfo={this.setRemovedCustomerInfo}
                  storageId={$('meta[name=user_storage]').attr("content")}
                />
              </div>
            )}

            {this.state.currentCustomer === 0 && this.state.showChatMessagesSelect && (
              <SelectChatLabel/>
            )}

            {this.state.currentCustomer !== 0 && this.state.showChatMessages && (
              <div className="col-xs-12 col-sm-6">
                <ChatMessages
                  currentCustomer={this.state.currentCustomer}
                  customerDetails={this.state.currentCustomerDetails}
                  removedCustomer={this.state.removedCustomer}
                  removedCustomerId={this.state.removedCustomerId}
                  newAgentAssignedId={this.state.newAgentAssignedId}
                  toggleFastAnswers={this.toggleFastAnswers}
                  selectedFastAnswer={this.state.selectedFastAnswer}
                  changeFastAnswer={this.changeFastAnswer}
                  onMobile={this.state.onMobile}
                  backToChatList={this.backToChatList}
                  editCustomerDetails={this.editCustomerDetails}
                  toggleProducts={this.toggleProducts}
                  selectProduct={this.selectProduct}
                  selectedProduct={this.state.selectedProduct}
                />
              </div>
            )}

            {this.state.currentCustomer !== 0 &&
            this.state.showFastAnswers === false &&
            this.state.showProducts === false &&
            this.state.showCustomerDetails &&
              <div className="col-xs-12 col-sm-3">
                <CustomerDetails
                  customerId={this.state.currentCustomer}
                  chatType='facebook_chats'
                  onMobile={this.state.onMobile}
                  backToChatMessages={this.backToChatMessages}
                />
              </div>
            }

            {this.state.currentCustomer !== 0 &&
            this.state.showFastAnswers &&
              <div className="col-xs-12 col-sm-3">
                <FastAnswers
                  chatType='facebook'
                  changeFastAnswer={this.changeFastAnswer}
                  toggleFastAnswers={this.toggleFastAnswers}
                  onMobile={this.state.onMobile}
                />
              </div>
            }

            {this.state.currentCustomer !== 0 &&
            this.state.showProducts &&
              <div className="col-xs-12 col-sm-3">
                <Products
                  onMobile={this.state.onMobile}
                  toggleProducts={this.toggleProducts}
                  selectProduct={this.selectProduct}
                />
              </div>
            }
          </div>
        </div>
      </div>
    )
  }
}

export default Chat;
