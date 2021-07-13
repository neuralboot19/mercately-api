import React from 'react';
import Select from 'react-select';

const FilterType = ({
  typeOptions,
  handleAddOptionToFilter,
  getPlaceholder
}) => (
  <div className="my-16">
    <p className="variations-label-bold">
      Filtrar por:
    </p>
    <Select
      className="react-select-container"
      classNamePrefix="react-select"
      options={typeOptions}
      onChange={(e) => handleAddOptionToFilter(e.value, 'type')}
      placeholder={getPlaceholder(typeOptions, 'type')}
    />
  </div>
);

export default FilterType;
