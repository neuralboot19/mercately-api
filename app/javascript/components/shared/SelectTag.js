import React from 'react';
import Select from 'react-select';

const SelectTag = ({
  tagsOptions,
  handleAddOptionToFilter,
  getPlaceholder
}) => (
  <div className="my-16">
    <p className="variations-label-bold">
      Etiquetas:
    </p>
    <Select
      className="react-select-container"
      classNamePrefix="react-select"
      options={tagsOptions}
      onChange={(e) => handleAddOptionToFilter(e.value, 'tag')}
      placeholder={getPlaceholder(tagsOptions, 'tag')}
    />
  </div>
);

export default SelectTag;
