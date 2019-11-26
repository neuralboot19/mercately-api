import React, { Component } from 'react';
import { Link } from "react-router-dom";

class ChatSelector extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div className="profile fs-14 box">
        <Link to="/retailers/pruebasasd/whatsapp" className="no-style">
          <div className="profile__data row">
            <div className="img__profile col-xs-2 p-0"><img src="https://cdn.kastatic.org/ka-perseus-graphie/8fae3d3d46f863fa793a6a3f3e6a200705716d9b.svg" alt="" className="rounded-circle mw-100"/></div>
            <div className="col-xs-10">
              <div className="profile__name">Daniel Ortin</div>
              <div className="chat_msg">
                Ultimo mensaje
                11/10
                ✔✔
              </div>
            </div>
          </div>
        </Link>
      </div>
    );
  }
}
export default ChatSelector;
