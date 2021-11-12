import React, { Component } from "react";
import Modal from 'react-modal';
import Dropzone from "react-dropzone";
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';

class ImagesSelector extends Component {
  constructor(props) {
    super(props)
  }

  preventKey = (e) => {
    e.preventDefault();
    return;
  }

  callPasteImages = (e) => {
    e.preventDefault();
    this.props.pasteImages(e, true);
  }

  render() {
    const fsTitle = this.props.onMobile ? 'fs-16' : 'fs-24';
    
    return (
      <Modal appElement={document.getElementById("react_content")} isOpen={this.props.showLoadImages} style={modalCustomStyles(this.props.onMobile)}>
        <div className={this.props.onMobile ? "d-flex justify-content-between" : "d-flex justify-content-between" }>
          <div>
            <p className={`font-weight-bold ${fsTitle}`}>Imágenes</p>
          </div>
          <div className="t-right">
            <a className="px-8" onClick={(e) => this.props.toggleLoadImages()}>
              <CloseIcon className="fill-dark" />
            </a>
          </div>
        </div>
        <div>
          <div>
            <Dropzone onDrop={this.props.onDrop} accept="image/jpg, image/jpeg, image/png">
              {({getRootProps, getInputProps}) => (
                <section>
                  <div {...getRootProps()} className="selector-container " suppressContentEditableWarning={true} contentEditable="true" onKeyDown={(e) => this.preventKey(e)} onPaste={(e) => this.callPasteImages(e)}>
                    <input {...getInputProps()} />
                    <div className="indicators">
                      <i className="far fa-arrow-alt-circle-down fs-35 c-grey"></i>
                      <p className="c-grey">Selecciona, pega o arrastra máximo 5 imágenes</p>
                    </div>
                  </div>
                </section>
              )}
            </Dropzone>
            {this.props.loadedImages.length > 0 &&
              <div>
                <div className="preview-container d-md-flex mt-30">
                  {this.props.loadedImages.map((image, index) =>
                    <div key={index} className="flex-center-xy">
                      <div className="div-image mr-15">
                        <i className="fas fa-times-circle cursor-pointer" onClick={() => this.props.removeImage(index)}></i>
                        <img src={URL.createObjectURL(image)} className="image-selected" />
                      </div>
                    </div>
                  )}
                </div>
                <div className="d-flex justify-content-center mt-30 mx-0 justify-content-md-end">
                    <div className={this.props.onMobile ? "mr-5" : "mr-15"}>
                      <a className="bg-light border-8 p-12 text-gray-dark border-gray" onClick={(e) => this.props.toggleLoadImages()}>Cancelar</a>
                    </div>
                    <div>
                      <a className="bg-blue border-8 text-white p-12" onClick={(e) => this.props.sendImages()}>Enviar</a>
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
