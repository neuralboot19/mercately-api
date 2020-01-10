import React, { Component } from "react";

class ImgModal extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  render() {
    return (
      <div className="img_modal">
        <div className="img_modal__overlay" onClick={(e) => this.props.toggleImgModal(e)}>
        </div>
        <img src={this.props.url} />
      </div>
    )
  }
}

export default ImgModal;
