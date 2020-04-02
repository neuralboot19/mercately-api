import React, { Component } from "react";
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
    let customer = this.props.customer
    return (
      <div className={`profile fs-14 box ${this.props.currentCustomer == customer.id ? 'border border--secondary' : 'border border--transparent'}`} onClick={() => this.props.handleOpenChat(this.props.customer)}>
        <div className="profile__data row">
          <div className="img__profile col-xs-2 p-0">
            <div className="rounded-circle mw-100" >
              <p>{`${customer.first_name && customer.last_name ? `${customer.first_name.charAt(0)} ${customer.last_name.charAt(0)}` : '' }`}  </p>
            </div>
          </div>
          { this.props.chatType == 'facebook' && (
            <div className="col-xs-10">
              <div className="profile__name">{customer.first_name} {customer.last_name}</div>
              <div className={customer["unread_message?"] ? 'fw-bold' : ''}>
                {moment(customer.recent_message_date).locale('es').fromNow()}
              </div>
            </div>
          )}
          { this.props.chatType == 'whatsapp' && (
            <div className="col-xs-10">
              <div className="profile__name">
                {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.phone}`}
              </div>
              <div className={customer["karix_unread_message?"] ? 'fw-bold' : ''}>
                {moment(customer.recent_message_date || customer.recent_inbound_message_date).locale('es').fromNow()}
              </div>
              <div>
                <small>{this.agentName(customer.assigned_agent)}</small>
              </div>
            </div>
          )}
        </div>
      </div>
    )
  }
}

export default ChatListUser;
