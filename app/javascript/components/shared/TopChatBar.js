import React, { useState, useEffect, useRef } from 'react';
import { useDispatch } from 'react-redux';
import Select from 'react-select';
// eslint-disable-next-line import/no-unresolved
import MailLunreadIcon from 'images/mail-unread-line.svg';
// eslint-disable-next-line import/no-unresolved
import ArrowDownIcon from 'images/arrowDown.svg';
import { fetchCustomer as fetchCustomerAction } from "../../actions/actions";
import BotIcon from '../icons/BotIcon'

const TopChatBar = ({
  activeChatBot,
  agentsList,
  customer,
  customerDetails,
  handleAgentAssignment,
  newAgentAssignedId,
  setNoRead,
  toggleChatBot,
  onMobile,
  toggleOptions,
  showOptions,
  chatType
}) => {
  const [agentsOptions, setAgentsOptions] = useState([]);
  const [selectedAgent, setSelectedAgent] = useState("");
  const [isUnreadChat, setIsUnreadChat] = useState(false);
  const isMounted = useRef(false);

  const getAgentLabel = (agent) => (
    agent.first_name && agent.last_name ? `${agent.first_name} ${agent.last_name}` : agent.email
  );

  const dispatch = useDispatch();

  useEffect(() => {
    setAgentsOptions([
      { value: "", label: "No asignado" },
      ...agentsList.map((agent) => ({
        value: agent.id,
        label: getAgentLabel(agent)
      }))]);
  }, [agentsList]);

  const fetchCustomerFromRedux = (id) => {
    onMobile && dispatch(fetchCustomerAction(id));
  };

  useEffect(() => {
    const xxx = newAgentAssignedId || customerDetails.assigned_agent.id || '';
    setIsUnreadChat(false);
    if (isMounted.current) {
      const label = agentsOptions.find((agent) => agent.value === xxx);
      setSelectedAgent(label?.label || '');
    } else {
      isMounted.current = true;
      fetchCustomerFromRedux(customerDetails.id);
    }
  }, [agentsOptions, customer, customerDetails]);

  const handleChange = (agentOption) => {
    setSelectedAgent(agentsOptions.find((agent) => agent.value === agentOption.value).label || '');
    handleAgentAssignment(agentOption);
  };

  const handleUnreadChat = (e) => {
    setIsUnreadChat(true);
    setNoRead(e);
  };

  const fullName = customer?.first_name || customer?.last_name
    ? `${customer.first_name || ''} ${customer.last_name || ''}`
    : customer?.email;

  const allowStartBot = activeChatBot || customer?.allow_start_bots;

  const botIconColor = allowStartBot ? 'fill-blue' : 'fill-gray-icon';

  const bgBotBtn = allowStartBot ? 'bg-blue-btn' : 'bg-light';

  const botTooltiptext = allowStartBot ? 'Desactivar' : 'Activar';

  return (
    <>
      <p className="text-right m-0 fs-12 text-gray-dark mx-16 d-md-none" onClick={toggleOptions}>
        <span className="border-8 bg-light px-8">
          {showOptions ? 'ocultar opciones' : 'Mas Opciones'}
          <img src={ArrowDownIcon} alt="arrow down icon" className={showOptions ? 'ml-4 rotate-180' : 'ml-4'} />
        </span>
      </p>
      {showOptions && (
        <div className="top-chat-bar">
          <div className="d-flex justify-content-between align-items-center">
            <div>
              <p className="font-weight-bolder fs-16 m-0 d-none d-md-block text-gray-dark name-top-chat-bar">{fullName || ''}</p>
            </div>

            <div className="flex-grow-1 d-flex justify-content-end">
              <button
                type="button"
                onClick={(e) => handleUnreadChat(e)}
                className="d-flex justify-content-center align-items-center p-12 bg-light border-8 cursor-pointer border-0 mr-8 tooltip-top"
              >
                <div className="tooltip-top">
                  <div className="tooltiptext">Marcar como no leído</div>
                  <span className="fs-sm-and-down-12 fs-14 text-gray-dark font-weight-normal ">
                    <img src={MailLunreadIcon} className="fill-gray-icon" alt="mail unread icon" />
                  </span>
                </div>
              </button>
              {chatType !== 'instagram' && (
                <button
                  className={`d-flex justify-content-center align-items-center p-12 border-8 cursor-pointer border-0 mr-8 ${bgBotBtn}`}
                  onClick={(e) => toggleChatBot(e)}
                >
                  <div className="tooltip-top">
                    <div className="tooltiptext">{botTooltiptext} bot</div>
                    <BotIcon className={botIconColor} />
                  </div>
                </button>
              )}
              <Select
                className="react-select-container fs-14 w-select-top-chat"
                classNamePrefix="react-select"
                options={agentsOptions}
                value={newAgentAssignedId || customerDetails.assigned_agent.id || ''}
                onChange={(e) => handleChange(e)}
                placeholder={selectedAgent}
              />
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default TopChatBar;
