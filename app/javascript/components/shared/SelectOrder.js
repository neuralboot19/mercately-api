import React from 'react';
import Select from 'react-select';

const SelectAgent = ({
  orderOptions,
  getPlaceholder,
  handleChatOrdering
}) => (
  <div className="my-16">
    <p className="variations-label-bold">
      Ordenar por:
    </p>
    <Select
      className="react-select-container"
      classNamePrefix="react-select"
      options={orderOptions}
      onChange={(e) => handleChatOrdering(e)}
      placeholder={getPlaceholder(orderOptions, 'order')}
    />
  </div>
);

export default SelectAgent;
