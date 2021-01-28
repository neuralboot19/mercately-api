import React from 'react';

const ChatFilter = (
  {
    agent,
    agents,
    filterTags,
    handleChatOrdering,
    handleSearchInputValueChange,
    handleKeyPress,
    handleAddOptionToFilter,
    order,
    searchString,
    tag,
    type
  }
) => {
  const getAgentName = (currentAgent) => {
    if (currentAgent.first_name && currentAgent.last_name) {
      return `${currentAgent.first_name} ${currentAgent.last_name}`;
    }
    return currentAgent.email;
  };

  return (
    <div className="chat__control">
      <input
        type="text"
        value={searchString}
        onChange={handleSearchInputValueChange}
        placeholder="Buscar"
        style={{
          width: "95%",
          borderRadius: "5px",
          marginBottom: "5px",
          border: "1px solid #ddd",
          padding: "8px"
        }}
        className="form-control"
        onKeyPress={handleKeyPress}
      />

      <div
        style={{
          margin: "0"
        }}
      >
        <p
          style={{
            display: "inline-block",
            margin: "0",
            marginBottom: "5px",
            width: "100%"
          }}
        >
          Filtrar por:&nbsp;&nbsp;
          <select
            style={{
              float: 'right',
              fontSize: '12px',
              maxWidth: "200px"
            }}
            id="type"
            value={type}
            onChange={() => handleAddOptionToFilter('type')}
          >
            <option value="all">Todos</option>
            <option value="no_read">No leídos</option>
            <option value="read">Leídos</option>
          </select>
        </p>
        <p
          style={{
            display: "inline-block",
            margin: "0",
            marginBottom: "5px",
            width: "100%"
          }}
        >
          Agente:&nbsp;&nbsp;
          <select
            style={{
              float: 'right',
              fontSize: '12px',
              maxWidth: "200px"
            }}
            id="agents"
            value={agent}
            onChange={() => handleAddOptionToFilter('agent')}
          >
            <option value="all">Todos</option>
            <option value="not_assigned">No asignados</option>
            {agents.map((currentAgent) => (
              <option
                value={currentAgent.id}
                key={currentAgent.id}
              >
                {getAgentName(currentAgent)}
              </option>
            ))}
          </select>
        </p>
        <p
          style={{
            display: "inline-block",
            margin: "0",
            marginBottom: "5px",
            width: "100%"
          }}
        >
          Etiquetas:&nbsp;&nbsp;
          <select
            style={{
              float: 'right',
              fontSize: '12px',
              maxWidth: "200px"
            }}
            id="tags"
            value={tag}
            onChange={() => handleAddOptionToFilter('tag')}
          >
            <option value="all">Todos</option>
            {filterTags.map((currentTag) => (
              <option value={currentTag.id} key={currentTag.id}>{currentTag.tag}</option>
            ))}
          </select>
        </p>
        <p
          style={{
            display: "inline-block",
            margin: "0",
            marginBottom: "5px",
            width: "100%"
          }}
        >
          Ordenar por:&nbsp;&nbsp;
          <select
            style={{
              float: 'right',
              fontSize: '12px',
              maxWidth: "200px"
            }}
            id="order"
            value={order}
            onChange={handleChatOrdering}
          >
            <option value="received_desc">Reciente - Antíguo</option>
            <option value="received_asc">Antíguo - Reciente</option>
          </select>
        </p>
      </div>
    </div>
  );
};

export default ChatFilter;
