import React, { Component } from "react";
import ChatList from '../shared/ChatList';
import ChatMessages from '../WhatsApp/ChatMessages';
import CustomerDetails from './../shared/CustomerDetails';


class WhatsApp extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null
    };
  }

  handleOpenChat = (customer_details) => {
    customer_details["karix_unread_message?"] = false;
    this.setState({
      ...this.state,
      currentCustomer: customer_details.id,
      currentCustomerDetails: customer_details,
      removedCustomer: null,
      removedCustomerId: null,
      newAgentAssignedId: null
    });
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
                  />
                </div>
            )}

            {this.state.currentCustomer != 0 &&
              <div className="col-sm-3">
                <CustomerDetails
                  customerDetails={this.state.currentCustomerDetails}
                  chatType='whatsapp_chats'
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
