import React from 'react';
import Select from 'react-select';

const SelectStatusChat = ({
  statusChatOptions,
  handleAddOptionToFilter,
  getPlaceholder
}) => (
  <div className="my-16">
    <p className="variations-label-bold">
      Estado:
    </p>
    <Select
      className="react-select-container"
      classNamePrefix="react-select"
      options={statusChatOptions}
      onChange={(e) => handleAddOptionToFilter(e.value, 'status')}
      placeholder={getPlaceholder(statusChatOptions, 'status')}
    />
  </div>
);

export default SelectStatusChat;
