import React, { Component } from "react";

class ChatListUser extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  render() {
    let customer = this.props.customer
    return (
      <div className={`profile fs-14 box ${this.props.currentCustomer == customer.id ? 'border border--secondary' : 'border border--transparent'}`} onClick={() => this.props.handleOpenChat(this.props.customer)}>
        <div className="profile__data row">
          <div className="img__profile col-xs-2 p-0">
            <div className="rounded-circle mw-100" >
              <p>{customer.first_name.charAt(0)} {customer.last_name.charAt(0)}</p>
            </div>
          </div>
          <div className="col-xs-10">
            <div className="profile__name">{customer.first_name} {customer.last_name}</div>

            <div>Hace 23 mins</div>
          </div>
        </div>
      </div>
    )
  }
}

export default ChatListUser;
