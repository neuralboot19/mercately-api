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

var auxOptions;

class SelectableField extends Component {
   constructor(props) {
     super(props)
     this.state = {
      selected: null,
      isUpdated: false
    };
   }

  componentDidUpdate(prevProps) {
    if (!prevProps.isTag) {
      if (this.state.selected == null){
        this.findSelectedOption(this.props.selected)
      } else {
        if (prevProps.selected !== this.state.selected.value && this.state.isUpdated == true){
          this.setState({isUpdated: false}, () => {
            this.findSelectedOption(this.props.selected)
          })
        }
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

  prepareTagOptions = (options) => {
    auxOptions = [];
    options.forEach(tag => {
      auxOptions.push({ value: tag.id, label: tag.tag });
    })

    return auxOptions;
  }

  render() {
    return (
     <Select
        value={this.state.selected}
        onChange={this.props.isTag ? this.props.handleSelectTagChange : this.props.handleSelectChange}
        options={this.props.isTag ? this.prepareTagOptions(this.props.options) : options}
        className="details-select-container"
        classNamePrefix="details-select"
        placeholder="Seleccionar"
        styles={customStyles}
      />
    )
  }
}

export default SelectableField;
