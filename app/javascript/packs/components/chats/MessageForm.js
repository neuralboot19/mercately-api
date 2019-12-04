import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { sendMessage } from "../../actions/actions";

var _updated = true;

const csrfToken = document.querySelector('[name=csrf-token]').content

class MessageForm extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: ''
    };
  }

  handleInputChange = (e) => {
    this.setState({
      [e.target.name]: e.target.value
    })
  }

  handleSubmit = (e) => {
    e.preventDefault();
    let text = { message: this.state.messageText }

    this.setState({ messageText: '' }, () => {
      this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
    });
  }

  render() {
    return (
      <div>
        <textarea className='input' name="messageText" placeholder="Mensaje" value={this.state.messageText} onChange={this.handleInputChange}></textarea>
        <button onClick={(e) => this.handleSubmit(e)}> Save</button>
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
    sendMessage: (id, message, token) => {
      dispatch(sendMessage(id, message, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withRouter(MessageForm));
