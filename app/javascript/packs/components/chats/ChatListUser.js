import React, { Component } from "react";

class ChatListUser extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  render() {
    let sawDate = new Date(this.props.customer.message_data.created_at);

    return (
      <div className="profile fs-14 box">
        <div className="profile__data row">
          <div className="img__profile col-xs-2 p-0">
            <img src="https://cdn.kastatic.org/ka-perseus-graphie/8fae3d3d46f863fa793a6a3f3e6a200705716d9b.svg" alt="" className="rounded-circle mw-100"/>
          </div>
          <div className="col-xs-10">
            <div className="profile__name">{this.props.customer.first_name} {this.props.customer.last_name}</div>
            <div className="chat_msg">
              {this.props.customer.message_data.text}
              {sawDate.getDate()}/{sawDate.getMonth() + 1}
              ✔✔
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default ChatListUser;
