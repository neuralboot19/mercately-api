import React, { useEffect, useState } from "react";
import Select from 'react-select';

const customStyles = {
  control: (base) => ({
    ...base,
    minHeight: 27
  })
};

const SelectableCustomField = ({
  handleSelectChange,
  options,
  selected
}) => {
  const [selectedOption, setSelectedOption] = useState();

  useEffect(() => {
    findSelectedOption();
  }, [selected]);

  const findSelectedOption = () => {
    setSelectedOption(options.find((element) => (element.value === selected)));
  };

  return (
    <Select
      value={selectedOption}
      onChange={handleSelectChange}
      options={options}
      className="details-select-container"
      classNamePrefix="details-select"
      placeholder="Seleccionar"
      styles={customStyles}
    />
  );
};

export default SelectableCustomField;
