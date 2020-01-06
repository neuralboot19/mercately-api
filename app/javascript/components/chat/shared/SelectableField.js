import React, { Component } from "react";
import Select from 'react-select';

const options = [
  { value: 'cedula', label: 'Cedula' },
  { value: 'pasaporte', label: 'Pasaporte' },
  { value: 'ruc', label: 'Ruc' },
];

const customStyles = {
  control: base => ({
    ...base,
    height: 27,
    minHeight: 27
  })
};


class SelectableField extends Component {
   constructor(props) {
     super(props)
     this.state = {
      selected: null,
    };
   }

  componentDidUpdate(prevProps) {
    if (this.state.selected == null){
      this.findSelectedOption(this.props.selected)
    }
  }

  findSelectedOption = (option) => {
    options.find((element) => {
      if (element.value === option){
        this.setState({selected: element});
      };
    })
  }

  render() {
    return (
     <Select
        value={this.state.selected}
        onChange={this.props.handleSelectChange}
        options={options}
        className="details-select-container"
        classNamePrefix="details-select"
        styles={customStyles}
      />
    )
  }
}

  export default SelectableField;