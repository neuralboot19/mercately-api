import React from 'react';
import Select from 'react-select';

const SelectAgent = ({
  agentsOptions,
  handleAddOptionToFilter,
  getPlaceholder
}) => (
  <div className="my-16">
    <p className="variations-label-bold">
      Agente:
    </p>
    <Select
      className="react-select-container"
      classNamePrefix="react-select"
      options={agentsOptions}
      onChange={(e) => handleAddOptionToFilter(e.value, 'agent')}
      placeholder={getPlaceholder(agentsOptions, 'agent')}
    />
  </div>
);

export default SelectAgent;
