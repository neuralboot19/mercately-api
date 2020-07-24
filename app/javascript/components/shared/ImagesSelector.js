import React, { Component } from "react";
import Modal from 'react-modal';
import Dropzone from "react-dropzone";

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

class ImagesSelector extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <Modal isOpen={this.props.showLoadImages} style={customStyles}>
        <div className={this.props.onMobile ? "row mt-50" : "row" }>
          <div className="col-md-10">
            <p className={this.props.onMobile ? "fs-20 mt-0" : "fs-30 mt-0" }>Imágenes</p>
          </div>
          <div className="col-md-2 t-right">
            <button onClick={(e) => this.props.toggleLoadImages()}>Cerrar</button>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            <Dropzone onDrop={this.props.onDrop} accept="image/jpg, image/jpeg, image/png">
              {({getRootProps, getInputProps}) => (
                <section>
                  <div {...getRootProps()} className="selector-container">
                    <input {...getInputProps()} />
                    <div className="indicators">
                      <i className="far fa-arrow-alt-circle-down fs-35 c-grey"></i>
                      <p className="c-grey">Selecciona o arrastra máximo 5 imágenes</p>
                    </div>
                  </div>
                </section>
              )}
            </Dropzone>
            {this.props.loadedImages.length > 0 &&
              <div>
                <div className="preview-container row mt-30">
                  {this.props.loadedImages.map((image, index) =>
                    <div className="div-image mr-15">
                      <i className="fas fa-times-circle cursor-pointer" onClick={() => this.props.removeImage(index)}></i>
                      <img src={URL.createObjectURL(image)} className="image-selected" />
                    </div>
                  )}
                </div>
                <div className="row mt-30">
                  <div className="col-md-6 t-right">
                    <button onClick={(e) => this.props.toggleLoadImages()}>Cancelar</button>
                  </div>
                  <div className="col-md-6 t-left">
                    <button onClick={(e) => this.props.sendImages()}>Enviar</button>
                  </div>
                </div>
              </div>
            }
          </div>
        </div>
      </Modal>
    )
  }
}

export default ImagesSelector;
