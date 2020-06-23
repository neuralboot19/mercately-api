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

  handleFileSubmit = (e) => {
    var el = e.target;
    var file = el.files[0];

    if(!['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(file.type)) {
      alert('Error: El archivo debe ser de tipo PDF o Word');
      return;
    }

    // Max 20 Mb allowed
    if(file.size > 20*1024*1024) {
      alert('Error: Maximo permitido 20MB');
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

  componentWillReceiveProps(newProps){
    if (newProps.fastAnswerText) {
      this.setState({
        messageText: newProps.fastAnswerText
      })
      this.props.emptyFastAnswerText();
    }

    if (newProps.selectedProduct) {
      var productString = '';
      productString += (newProps.selectedProduct.attributes.title + '\n');
      productString += ('Precio $' + newProps.selectedProduct.attributes.price + '\n');
      productString += (newProps.selectedProduct.attributes.description + '\n');
      productString += (newProps.selectedProduct.attributes.url ? newProps.selectedProduct.attributes.url : '');
      this.state.messageText = productString;
    }
  }

  render() {
    return (
      <div className="text-input">
        <textarea name="messageText" placeholder="Escribe un mensaje aquí" autoFocus value={this.state.messageText} onChange={this.handleInputChange} onKeyPress={this.onKeyPress}></textarea>
        {this.props.selectedProduct && this.props.selectedProduct.attributes.image &&
          <div className="selected-product-image-container">
            <i className="fas fa-times-circle cursor-pointer" onClick={() => this.props.removeSelectedProduct()}></i>
            <img src={this.props.selectedProduct.attributes.image} />
          </div>
        }
        <div className="t-right mr-15">
          <input id="attach-file" className="d-none" type="file" name="messageFile" accept="application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document" onChange={(e) => this.handleFileSubmit(e)}/>
          <div className="tooltip-top">
            <i className="fas fa-paperclip fs-22 ml-7 mr-7 cursor-pointer" onClick={() => document.querySelector('#attach-file').click()}></i>
            {this.props.onMobile == false &&
              <div className="tooltiptext">Archivos</div>
            }
          </div>
          <input id="attach" className="d-none" type="file" name="messageImg" accept="image/*" onChange={(e) => this.handleImgSubmit(e)}/>
          <div className="tooltip-top">
            <i className="fas fa-image fs-22 ml-7 mr-7 cursor-pointer" onClick={() => document.querySelector('#attach').click()}></i>
            {this.props.onMobile == false &&
              <div className="tooltiptext">Imágenes</div>
            }
          </div>
          <div className="tooltip-top">
            <i className="fas fa-bolt fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.props.toggleFastAnswers()}></i>
            {this.props.onMobile == false &&
              <div className="tooltiptext">Respuestas Rápidas</div>
            }
          </div>
          <div className="tooltip-top">
            <i className="fas fa-shopping-bag fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.props.toggleProducts()}></i>
            {this.props.onMobile == false &&
              <div className="tooltiptext">Productos</div>
            }
          </div>
          <div className="tooltip-top ml-15"></div>
          <div className="tooltip-top">
            <i className="fas fa-paper-plane fs-22 mr-5 c-secondary cursor-pointer" onClick={(e) => this.handleSubmit(e)}></i>
            {this.props.onMobile == false &&
              <div className="tooltiptext">Enviar</div>
            }
          </div>
        </div>
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
