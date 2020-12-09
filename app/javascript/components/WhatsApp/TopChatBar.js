import React from 'react';

const TopChatBar = (
  {
    activeChatBot,
    agentsList,
    customer,
    customerDetails,
    handleAgentAssignment,
    newAgentAssignedId,
    onMobile,
    setNoRead,
    toggleChatBot
  }) => {
  return (
    <div className="top-chat-bar pl-10">
      <div className='assigned-to'>
        <small>Asignado a: </small>
        <select id="agents"
                value={newAgentAssignedId || customerDetails.assigned_agent.id || ''}
                onChange={(e) => handleAgentAssignment(e)}>
          <option value="">No asignado</option>
          {agentsList.map((agent, index) => (
            <option value={agent.id}
                    key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
          ))}
        </select>
      </div>
      {activeChatBot && onMobile === false &&
      <div className="tooltip-top chat-bot-icon">
        <i className="fas fa-robot c-secondary fs-15"></i>
        <div className="tooltiptext">ChatBot Activo</div>
      </div>
      }
      <div className='mark-no-read'>
        <button onClick={(e) => setNoRead(e)} className='btn btn--cta btn-small right'>Marcar
          como no leído
        </button>
        <button onClick={(e) => toggleChatBot(e)} className='btn btn--cta btn-small right'>
          {activeChatBot || (customer && customer.allow_start_bots) ?
            <span>Desactivar Bot</span>
            : <span>Activar Bot</span>
          }
        </button>
      </div>
    </div>
  )
}

export default TopChatBar;
