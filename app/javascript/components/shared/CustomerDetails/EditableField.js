import React, { Component, createRef } from "react";

class EditableField extends Component {
  constructor(props) {
    super(props);
    this.contentEditable = createRef();
  }

  press = (evt) => {
    if (evt.key === 'Enter') {
      evt.preventDefault();
      this.contentEditable.current.blur();
    }
  };

  render() {
    return (
      <input
        ref={this.contentEditable}
        value={this.props.content || ''}
        onChange={(e) => this.props.handleInputChange(e, this.props.targetName)}
        className={this.props.givenClass ? this.props.givenClass : "editable_field"}
        onBlur={() => this.props.handleSubmit()}
        onKeyDown={this.press}
        placeholder={this.props.placeholder}
      />
    );
  }
}

export default EditableField;
