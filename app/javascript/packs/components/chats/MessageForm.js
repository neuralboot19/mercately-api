import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { sendMessage } from "../../actions/actions";

import ChatMessage from './ChatMessage';

var _updated = true;
class MessageForm extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: ''
    };
  }

  handleInputChange = (e) => {
    this.setState({
      messageText: {
        ...this.state.messageText,
        [e.target.name]: e.target.value
      }
    })
  }

  componentDidUpdate() {
    if(_updated) {
      this.setState({
        messageText: this.props.messageText
      })
    }
    _updated = false;
  }

  render() {
    return (
      <div>
        <form onSubmit={(e) => this.props.handleSubmit(e, this.state.messageText)}>
          <textarea className='input' name="message" placeholder="Mensaje" value={this.state.messageText} onChange={this.handleInputChange}></textarea>
          <button type="submit">Save</button>
        </form>
      </div>
    )
  }
}


function mapStateToProps(state) {
  return {
    messageText: state.messageText || [],
  };
}

function mapDispatchToProps(dispatch) {
  return {
    sendMessage: (id) => {
      dispatch(sendMessage(id));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withRouter(MessageForm));
