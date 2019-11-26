import React, { Component } from 'react';

import ChatSelector from '../components/ChatSelector';

class Chats extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div className="chat__selector">
        <ChatSelector/>
      </div>
    );
  }
}
export default Chats;
