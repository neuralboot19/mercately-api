import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import moment from 'moment';

class ChatListUser extends Component {
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

  render() {
    let customer = this.props.customer;
    return (
      <div className={`profile fs-14 box ${this.props.currentCustomer == customer.id ? 'border border--secondary chat-selected' : 'border border--transparent'}`} onClick={() => this.props.handleOpenChat(this.props.customer)}>
        <div className="profile__data row">
          {(customer.unread_chat === true || customer.unread_whatsapp_messages > 0 || customer["unread_whatsapp_message?"] === true) &&
            <div className="tooltip">
              <b className="item__cookie item__cookie_whatsapp_messages notification">
                {customer.unread_whatsapp_messages > 0 &&
                  customer.unread_whatsapp_messages
                }
              </b>
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
              </div>
              <div className={customer["unread_message?"] ? 'fw-bold' : ''}>
                {moment(customer.recent_message_date).locale('es').fromNow()}
              </div>
            </div>
          )}
          { this.props.chatType == 'whatsapp' && (
            <div className="col-xs-10 profile__info">
              <div className="profile__name">
                {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.whatsapp_name ? customer.whatsapp_name : customer.phone }`}&nbsp;&nbsp;
                { customer.last_whatsapp_message.direction === 'outbound' && customer['handle_message_events?'] === true &&
                  <i className={ `fas fa-${
                    customer.last_whatsapp_message.status === 'sent' ? 'check stroke' : (customer.last_whatsapp_message.status === 'delivered' ? 'check-double stroke' : ( customer.last_whatsapp_message.status === 'read' ? 'check-double black' : 'sync black'))
                  }`
                  }></i>
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
)(withRouter(ChatListUser));
