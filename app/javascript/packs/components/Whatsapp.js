import React, { Component } from 'react';
import { Link } from "react-router-dom";

class Chat extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div>
        <Link to="/retailers/pruebasasd/facebook_chats">facebook_chats</Link>
        <h1>Hola whatsapp</h1>
      </div>
    );
  }
}
export default Chat;
