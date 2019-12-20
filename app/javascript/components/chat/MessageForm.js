import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";

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
    let text = this.state.messageText;
    if(text.trim() === '') return;
    this.setState({ messageText: '' }, () => {
      this.props.handleSubmitMessage(e, text)
    });
  }

  handleImgSubmit = (e) => {
    var el = e.target;
    var file = el.files[0];
    if(!file.type.includes('image/')) {
      alert('Error: El archivo debe ser una imagen');
      return;
    }

    // Max 8 Mb allowed
    if(file.size > 8*1024*1024) {
      alert('Error: Maximo permitido 8MB');
      return;
    }

    var data = new FormData();
    data.append('file_data', file);
    this.props.handleSubmitImg(el, data);
  }

  onKeyPress = (e) => {
    if(e.which === 13) {
      e.preventDefault();
      this.handleSubmit(e);
    }
  }

  render() {
    return (
      <div className="text-input">
        <textarea name="messageText" placeholder="Mensaje" autoFocus value={this.state.messageText} onChange={this.handleInputChange} onKeyPress={this.onKeyPress}></textarea>
        <input id="attach" className="d-none" type="file" name="messageImg" accept="image/*" onChange={(e) => this.handleImgSubmit(e)}/>
        <i className="fas fa-camera fs-24 cursor-pointer" onClick={() => document.querySelector('#attach').click()}></i>
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
