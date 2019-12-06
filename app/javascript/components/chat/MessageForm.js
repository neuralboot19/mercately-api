import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { sendMessage } from "../../actions/actions";

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
    let text = this.state.messageText
    this.setState({ messageText: '' }, () => {
      this.props.handleSubmitMessage(e, text)
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

  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withRouter(MessageForm));