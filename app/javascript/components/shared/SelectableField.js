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
      isUpdated: false
    };
   }

  componentDidUpdate(prevProps) {

    if (this.state.selected == null){
      this.findSelectedOption(this.props.selected)
    } else {      
      console.log("ver que son", prevProps.selected, this.state.selected.value)
      if (prevProps.selected !== this.state.selected.value && this.state.isUpdated == true){
        this.setState({isUpdated: false}, () => {
          this.findSelectedOption(this.props.selected)
        })
      }      
    }

  }

  findSelectedOption = (option) => {
    options.find((element) => {
      if (element.value === option){
        this.setState({selected: element, isUpdated: true});
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