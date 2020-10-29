import React from 'react';

const TopChatBar = ({ agent_list, customerDetails, handleAgentAssignment, newAgentAssignedId, setNoRead }) => {
  return (
    <div className="top-chat-bar pl-10">
      <div className='assigned-to'>
        <small>Asignado a: </small>
        <select id="agents" value={newAgentAssignedId || customerDetails.assigned_agent.id || ''}
                onChange={(e) => handleAgentAssignment(e)}>
          <option value="">No asignado</option>
          {agent_list.map((agent, index) => (
            <option value={agent.id}
                    key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
          ))}
        </select>
      </div>
      <div className='mark-no-read'>
        <button onClick={(e) => setNoRead(e)} className='btn btn--cta btn-small right'>Marcar
          como no leído
        </button>
      </div>
    </div>

  )
}
export default TopChatBar