import React, { Component } from "react";
import WhatsAppChatList from '../WhatsApp/WhatsAppChatList';
import ChatMessages from '../WhatsApp/ChatMessages';
import CustomerDetails from '../chat/shared/CustomerDetails';


class WhatsApp extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      currentCustomerDetails: {},
    };
  }

  handleOpenChat = (customer_details) => {
    customer_details["karix_unread_message?"] = false;
    this.setState({
      ...this.state,
      currentCustomer: customer_details.id,
      currentCustomerDetails: customer_details
    });
  }

  render() {
    return (
      <div>
        <div className="box">
          <div className="row">
            <div className="col-sm-3 chat_list_holder">
              <WhatsAppChatList
                handleOpenChat={this.handleOpenChat}
                currentCustomer={this.state.currentCustomer}
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
