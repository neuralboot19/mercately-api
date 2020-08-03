import React, { Component } from "react";

class MessageForm extends Component {
  constructor(props) {
    super(props)
  }

  handleSubmit = (e) => {
    let input = $('#divMessage');
    let text = input.text();
    if (text.trim() === '' && this.selectionPresent() === false) return;

    let txt = this.getText();
    this.props.handleSubmitMessage(e, txt)
    input.html(null);
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
    if (newProps.selectedFastAnswer) {
      $('#divMessage').html(newProps.selectedFastAnswer.attributes.answer);
    }

    if (newProps.selectedProduct) {
      var productString = '';
      productString += (newProps.selectedProduct.attributes.title + '\n');
      productString += ('Precio $' + newProps.selectedProduct.attributes.price + '\n');
      productString += (newProps.selectedProduct.attributes.description + '\n');
      productString += (newProps.selectedProduct.attributes.url ? newProps.selectedProduct.attributes.url : '');
      $('#divMessage').html(productString);
    }
  }

  getText = () => {
    let input = $('#divMessage');
    let txt = input.html();

    return txt.replace(/<br>/g, "\n");
  }

  selectionPresent = () => {
    if (this.props.objectPresence()) {
        return true;
      } else {
        return false;
      }
  }

  render() {
    return (
      <div className="text-input">
        <div id="divMessage" contentEditable="true" role="textbox" placeholder-text="Escribe un mensaje aquí" className="message-input fs-14" onPaste={(e) => this.props.pasteImages(e)} onKeyPress={this.onKeyPress} tabIndex="0">
        </div>
        {this.props.selectedProduct && this.props.selectedProduct.attributes.image &&
          <div className="selected-product-image-container">
            <i className="fas fa-times-circle cursor-pointer" onClick={() => this.props.removeSelectedProduct()}></i>
            <img src={this.props.selectedProduct.attributes.image} />
          </div>
        }
        {this.props.selectedFastAnswer && this.props.selectedFastAnswer.attributes.image_url &&
          <div className="selected-product-image-container">
            <i className="fas fa-times-circle cursor-pointer" onClick={() => this.props.removeSelectedFastAnswer()}></i>
            <img src={this.props.selectedFastAnswer.attributes.image_url} />
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
          <div className="tooltip-top">
            <i className="fas fa-image fs-22 ml-7 mr-7 cursor-pointer" onClick={() => this.props.toggleLoadImages()}></i>
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

export default MessageForm;
