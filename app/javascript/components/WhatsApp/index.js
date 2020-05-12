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
      fastAnswerText: null
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
  }

  changeFastAnswerText = (text) => {
    this.setState({
      fastAnswerText: text
    })
  }

  render() {
    return (
      <div>
        <div className="box">
          <div className="row">
            <div className="col-sm-3 chat_list_holder">
              <ChatList
                handleOpenChat={this.handleOpenChat}
                currentCustomer={this.state.currentCustomer}
                chatType='whatsapp'
                setRemovedCustomerInfo={this.setRemovedCustomerInfo}
              />
            </div>

            {this.state.currentCustomer === 0 ? (
              <div className="col-sm-9">
                Selecciona un chat
              </div>
              ) : (
                <div className="col-sm-6">
                  <ChatMessages
                    currentCustomer={this.state.currentCustomer}
                    recentInboundMessageDate={this.state.currentCustomerDetails.recent_inbound_message_date}
                    customerDetails={this.state.currentCustomerDetails}
                    removedCustomer={this.state.removedCustomer}
                    removedCustomerId={this.state.removedCustomerId}
                    newAgentAssignedId={this.state.newAgentAssignedId}
                    toggleFastAnswers={this.toggleFastAnswers}
                    fastAnswerText={this.state.fastAnswerText}
                    changeFastAnswerText={this.changeFastAnswerText}
                  />
                </div>
            )}

            {this.state.currentCustomer != 0 && this.state.showFastAnswers == false &&
              <div className="col-sm-3">
                <CustomerDetails
                  customerDetails={this.state.currentCustomerDetails}
                  chatType='whatsapp_chats'
                />
              </div>
            }

            {this.state.currentCustomer != 0 && this.state.showFastAnswers &&
              <div className="col-sm-3">
                <FastAnswers
                  chatType='whatsapp'
                  changeFastAnswerText={this.changeFastAnswerText}
                  toggleFastAnswers={this.toggleFastAnswers}
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
