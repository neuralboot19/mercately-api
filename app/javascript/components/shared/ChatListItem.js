import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import moment from 'moment';

import WhatsAppProfileInfo from '../WhatsApp/WhatsAppProfileInfo';
import FacebookProfileInfo from '../chat/FacebookProfileInfo';

class ChatListItem extends Component {
  agentName = (agent) => {
    if (agent) {
      if (/^\s*$/.test(agent.email)) {
        return 'No asignado';
      }
      return /^\s*$/.test(agent.full_name) ? agent.email : agent.full_name;
    }
    return 'No asignado';
  }

  addBotPosition = () => {
    if (this.props.customer.unread_whatsapp_chat === true || this.props.customer.unread_whatsapp_messages > 0 ||
      this.props.customer["unread_whatsapp_message?"] === true || this.props.customer.unread_messenger_chat === true ||
      this.props.customer.unread_messenger_messages > 0 || this.props.customer["unread_message?"] === true) {
      return 'bot-position';
    }

    return '';
  }

  howLongAgo = () => moment(this.props.customer.recent_message_date).locale('es').fromNow(true);

  getChartAtToTicketStatus = () => (this.props.customer.whatsapp_name
    ? this.props.customer.whatsapp_name.charAt(0)
    : '');

  render() {
    const { customer } = this.props;

    const getTicketStatus = this.props.customer.first_name && this.props.customer.last_name
      ? `${this.props.customer.first_name.charAt(0)} ${this.props.customer.last_name.charAt(0)}`
      : this.getChartAtToTicketStatus();

    const containerClass = this.props.currentCustomer === customer.id
      ? 'chat-selected'
      : 'profile';

    return (
      <div>
        <div
          className={`${containerClass} m-2 profile-container`}
          onClick={() => this.props.handleOpenChat(this.props.customer)}
          customer-id={customer.id}
          chat-type={this.props.chatType}
        >
          <div className="fs-14 profile__data">
            <div className="row mx-0">
              <div className="img__profile col-2 p-0">
                <div className="ticket-status">
                  <p>
                    {getTicketStatus}
                  </p>
                </div>
              </div>
              { this.props.chatType === 'facebook' &&
                <FacebookProfileInfo
                  customer={customer}
                  howLongAgo={this.howLongAgo}
                  agentName={this.agentName}
                />
              }
              { this.props.chatType === 'whatsapp' &&
                <WhatsAppProfileInfo
                  customer={customer}
                  howLongAgo={this.howLongAgo}
                  agentName={this.agentName}
                />
              }
            </div>
          </div>

        </div>
        <hr className="chat_separator" />
      </div>
    );
  }
}

function mapState(state) {
  return {
    recentInboundMessageDate: state.recentInboundMessageDate || null,
    customerId: state.customerId || null
  };
}

export default connect(
  mapState
)(withRouter(ChatListItem));
