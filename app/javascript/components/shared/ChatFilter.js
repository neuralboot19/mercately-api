import React, { useEffect, useState } from 'react';
// eslint-disable-next-line import/no-unresolved
import FilterIcon from 'images/filter.svg';
// eslint-disable-next-line import/no-unresolved
import AppliedFilterIcon from 'images/AppliedFilterIcon.svg';
// eslint-disable-next-line import/no-unresolved
import SearchIcon from 'images/search.svg';
// eslint-disable-next-line import/no-unresolved
import CloseIcon from 'images/close.svg';

import SelectFilterType from './SelectFilterType';
import SelectAgent from './SelectAgent';
import SelectTag from './SelectTag';
import SelectOrder from './SelectOrder';
import ActiveFilters from './ActiveFilters';

const ChatFilter = (props) => {
  const {
    agents,
    filterTags,
    handleChatOrdering,
    handleSearchInputValueChange,
    handleKeyPress,
    handleAddOptionToFilter,
    searchString,
    openChatFilters,
    setOpenChatFilters,
    applySearch,
    cleanFilters,
    filterApplied
  } = props;

  const getAgentName = (currentAgent) => {
    if (currentAgent.first_name && currentAgent.last_name) {
      return `${currentAgent.first_name} ${currentAgent.last_name}`;
    }
    return currentAgent.email;
  };

  const getPlaceholder = (obj, key) => obj.find((item) => item.value === props[key])?.label;

  const isFilteredChatSelector = !openChatFilters && filterApplied;

  const [agentsOptions, setAgentsOptions] = useState([]);
  const [typeOptions] = useState([
    { value: 'all', label: 'Todos' },
    { value: 'no_read', label: 'No leídos' },
    { value: 'read', label: 'Leídos' }
  ]);
  const [tagsOptions, setTagsOptions] = useState([]);
  const [orderOptions] = useState([
    { value: 'received_desc', label: 'Reciente - Antíguo' },
    { value: 'received_asc', label: 'Antíguo - Reciente' }
  ]);

  const iconFilter = isFilteredChatSelector ? AppliedFilterIcon : FilterIcon;

  const getFilterIcons = openChatFilters ? CloseIcon : iconFilter;

  const toggleChatFilters = () => openChatFilters ? cleanFilters() : setOpenChatFilters(true);

  useEffect(() => {
    setTagsOptions([
      { value: 'all', label: 'Todos' },
      ...filterTags.map((currentTag) => ({
        value: currentTag.id,
        label: currentTag.tag
      }))
    ]);
  }, [filterTags]);

  useEffect(() => {
    setAgentsOptions([
      { value: 'all', label: 'Todos' },
      { value: 'not_assigned', label: 'No asignados' },
      ...agents.map((currentAgent) => ({
        value: currentAgent.id,
        label: getAgentName(currentAgent)
      }))
    ]);
  }, [agents]);

  return (
    <div className="chat-filter-holder">
      <div className="p-relative my-16">
        <input
          type="text"
          value={searchString}
          onChange={handleSearchInputValueChange}
          placeholder="Buscar"
          className="input-icon bg-light"
          onKeyPress={handleKeyPress}
        />
        <span
          className="p-absolute icon-search"
        >
          <img src={SearchIcon} alt="search icon" />
        </span>
        <div className="p-absolute btn-filter">
          <span onClick={toggleChatFilters}>
            <img src={getFilterIcons} alt="filter icon" />
          </span>
        </div>
      </div>
      {
        filterApplied && !openChatFilters
          ? (
            <ActiveFilters
              cleanFilters={cleanFilters}
            />
          ) : ''
      }
      { openChatFilters && (
        <>
          <SelectFilterType
            typeOptions={typeOptions}
            handleAddOptionToFilter={handleAddOptionToFilter}
            getPlaceholder={getPlaceholder}
          />
          <SelectAgent
            agentsOptions={agentsOptions}
            handleAddOptionToFilter={handleAddOptionToFilter}
            getPlaceholder={getPlaceholder}
          />
          <SelectTag
            tagsOptions={tagsOptions}
            handleAddOptionToFilter={handleAddOptionToFilter}
            getPlaceholder={getPlaceholder}
          />
          <SelectOrder
            orderOptions={orderOptions}
            handleAddOptionToFilter={handleAddOptionToFilter}
            getPlaceholder={getPlaceholder}
            handleChatOrdering={handleChatOrdering}
          />
          <div
            onClick={() => applySearch(0)}
            className="cursor-pointer border-8 text-center text-white bg-blue p-12 my-16"
          >
            Aplicar Filtro
          </div>
          <p
            onClick={cleanFilters}
            className="my-16 text-blue cursor-pointer border-8 text-center"
          >
            LIMPIAR
          </p>
        </>
      )}
    </div>
  );
};

export default ChatFilter;
