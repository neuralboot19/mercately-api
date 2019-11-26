import React, { Component } from 'react';
import { Link } from "react-router-dom";

class ChatSelector extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div>
        <Link to="/retailers/pruebasasd/whatsapp">wp</Link>
        <h1>Hola mundo</h1>
      </div>
    );
  }
}
export default ChatSelector;
