import React, { Component } from 'react';
import Modal from 'react-modal';
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';

class MultipleFastAnswer extends Component {
  constructor(props) {
    super(props)
  }

  formatUrl = (originalUrl) => {
    const formats = 'if_w_gt_200/c_scale,w_200/if_end/q_auto';
    return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
  }

  render() {
    const fsTitle = this.props.onMobile ? 'fs-12' : 'fs-20';

    return (
      <Modal appElement={document.getElementById("react_content")} isOpen={this.props.showMultipleAnswers} style={modalCustomStyles(this.props.onMobile)}>
        <div className={this.props.onMobile ? "d-flex justify-content-between" : "d-flex justify-content-between" }>
          <div>
            <div className={`font-weight-bold ${fsTitle}`}>{this.props.selectedAnswer?.attributes.title}</div>
          </div>
          <div className="t-right">
            <a className="px-8" onClick={(e) => this.props.toggleMultipleAnswersModal(e, null)}>
              <CloseIcon className="fill-dark" />
            </a>
          </div>
        </div>
        <div>
          <div className="divider"></div>
          <p className="mt-16">Respuestas adicionales</p>
          {this.props.selectedAnswer?.attributes.additional_fast_answers.data.map((afa) => (
            <div key={afa.id}>
              <label className="fs-14 c-secondary">Contenido:</label><br />
              <pre className="fs-12 mb-15 general-font-family">
                {afa.attributes.answer}
              </pre>
              {afa.attributes.file_type === 'image' && (
                <>
                  <label className="fs-14 c-secondary">Imagen:</label><br />
                  <img className="w-200 h-200" src={this.formatUrl(afa.attributes.file_url)} />
                </>
              )}
              {afa.attributes.file_type === 'file' && (
                <>
                  <label className="fs-14 c-secondary">Archivo:</label><br />
                  <embed className="w-200 h-200" width="200" height="200" src={afa.attributes.file_url} />
                </>
              )}
              <div className="divider"></div>
            </div>
          ))}
        </div>
      </Modal>
    )
  }
}

export default MultipleFastAnswer;
