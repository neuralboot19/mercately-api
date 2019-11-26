import React, { Component } from 'react';
import { BrowserRouter, Link  } from 'react-router-dom';

class Chat extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div>
        <BrowserRouter>
          <Link to="/retailers/pruebasasd/facebook_chats">facebook_chats</Link>
          <h1>Hola whatsapp</h1>
        </BrowserRouter>
      </div>
    );
  }
}
export default Chat;
