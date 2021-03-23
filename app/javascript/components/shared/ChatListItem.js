import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import moment from 'moment';

class ChatListItem extends Component {
  constructor(props) {
    super(props)
  }

  agentName = (agent) => {
    if (agent) {
      if (/^\s*$/.test(agent.email)) {
        return 'No asignado'
      } else {
        return /^\s*$/.test(agent.full_name) ? 'Asignado a ' + agent.email : 'Asignado a ' + agent.full_name;
      }
    } else {
      return 'No asignado';
    }
  }

  addBotPosition = () => {
    if (this.props.customer.unread_whatsapp_chat === true || this.props.customer.unread_whatsapp_messages > 0 ||
      this.props.customer["unread_whatsapp_message?"] === true || this.props.customer.unread_messenger_chat === true ||
      this.props.customer.unread_messenger_messages > 0 || this.props.customer["unread_message?"] === true) {
      return 'bot-position';
    }

    return '';
  }

  messageStatusIcon = (message) => {
    let className;
    switch (message.status) {
      case 'error':
        className = 'exclamation-circle';
        break;
      case 'sent':
        className = 'check stroke';
        break;
      case 'delivered':
        className = 'check-double stroke';
        break;
      case 'read':
        className = 'check-double black';
        break;
      default:
        className = message.content_type === 'text' ? 'check stroke' : 'sync black';
    }

    return className;
  }

  render() {
    const { customer } = this.props;

    const containerClass = this.props.currentCustomer === customer.id
      ? 'border border--secondary chat-selected'
      : 'border border--transparent';

    return (
      <div
        className={`profile fs-14 box ${containerClass}`}
        onClick={() => this.props.handleOpenChat(this.props.customer)}
        customer-id={customer.id}
        chat-type={this.props.chatType}
      >
        <div className="profile__data row">
          {this.props.chatType === 'facebook' ? (
              (customer.unread_messenger_chat === true || customer.unread_messenger_messages > 0 || customer['unread_message?'] === true) &&
                <div className="tooltip">
                  <b className="item__cookie item__cookie_whatsapp_messages notification">
                    {customer.unread_messenger_messages > 0 &&
                      customer.unread_messenger_messages
                    }
                  </b>
                </div>
            ) : (
              (customer.unread_whatsapp_chat === true || customer.unread_whatsapp_messages > 0 || customer["unread_whatsapp_message?"] === true) &&
                <div className="tooltip">
                  <b className="item__cookie item__cookie_whatsapp_messages notification">
                    {customer.unread_whatsapp_messages > 0 &&
                      customer.unread_whatsapp_messages
                    }
                  </b>
                </div>
            )
          }
          {this.props.customer.active_bot &&
            <div className="bot-icon-container">
              <i className={`fas fa-robot c-secondary fs-12 ${this.addBotPosition()}`}></i>
            </div>
          }
          <div className="img__profile col-xs-2 p-0">
            <div className="rounded-circle mw-100" >
              <p>{`${customer.first_name && customer.last_name ? `${customer.first_name.charAt(0)} ${customer.last_name.charAt(0)}` : customer.whatsapp_name ? customer.whatsapp_name.charAt(0) : '' }`}  </p>
            </div>
          </div>
          { this.props.chatType == 'facebook' && (
            <div className="col-xs-10 profile__info">
              <div className="profile__name">{customer.first_name} {customer.last_name}&nbsp;&nbsp;
                { customer.last_messenger_message.sent_by_retailer === true && customer.last_messenger_message.date_read &&
                  <i className="fas fa-check-double black"></i>
                }
                <div className={`fw-muted time-from`}>
                  {moment(customer.recent_message_date).locale('es').fromNow()}
                </div>
              </div>
              <div className={`${customer["unread_message?"] ? 'fw-bold' : ''}`}>
                <small>{this.agentName(customer.assigned_agent)}</small>
              </div>
            </div>
          )}
          { this.props.chatType == 'whatsapp' && (
            <div className="col-xs-10 profile__info">
              <div className="profile__name">
                {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.whatsapp_name ? customer.whatsapp_name : customer.phone }`}&nbsp;&nbsp;
                { customer.last_whatsapp_message.direction === 'outbound' && customer['handle_message_events?'] === true &&
                  <i className={ `fas fa-${this.messageStatusIcon(customer.last_whatsapp_message)}`}></i>
                }
                <div className="fw-muted time-from">
                  {moment(customer.recent_message_date).locale('es').fromNow()}
                </div>
              </div>
              <div className={`${customer["unread_whatsapp_message?"] ? 'fw-bold' : ''}`}>
                <small>{this.agentName(customer.assigned_agent)}</small>
              </div>
            </div>
          )}
          <div className="row mt-15 w-100 show-to-right">
            {customer.tags && customer.tags.length > 0 && customer.tags.map((tag, index) =>
              <div key={index} className="customer-tags-chats">
                {tag.tag}
              </div>
            )}
          </div>
        </div>
      </div>
    )
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
