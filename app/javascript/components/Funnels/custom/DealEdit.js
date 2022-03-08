import React, { useState, useEffect } from 'react';
import modalCustomStyles from '../../../util/modalCustomStyles';
import CloseIcon from '../../icons/CloseIcon';
import Modal from 'react-modal';
import { useDispatch, useSelector } from 'react-redux';
import AsyncSelect from 'react-select/async';
import {
  updateFunnelStepDeal,
  clearNewDeal
} from '../../../actions/funnels';

const customStyles = {
  option: (provided) => ({
    ...provided,
  }),
  control: (provided, state) => ({
    ...provided,
    background: '#F7F8FD',
    borderRadius: '12px',
    border: 'none',
    height: '48px',
    fontSize: '14px',
    color: '#3C4348',
    width: '100%'
  }),
  placeholder: (provided, state) => {
    return {
      ...provided,
      color: '#3C4348'
    }
  },
  menuPortal: base => ({ ...base, zIndex: 9999 })
};

const DealEdit = ({
  toggleEditDeal,
  deal,
  columnWebId,
  isOpen,
  reloadDeals
}) => {
  const dispatch = useDispatch();
  const dealSuccess = useSelector((reduxState) => reduxState.mainReducer.newDealSuccess) || false;
  const defaultDeal = { name: '', amount: '' };

  const [newDeal, setNewDeal] = useState({
    name: deal.name,
    amount: deal.amount,
    customerId: deal.customerId,
    selectedCustomer: deal.customer ? `${deal.customer.first_name} ${deal.customer.last_name}` : 'Seleccionar cliente',
    agentId: deal.agent.id || '',
    selectedAgent: deal.agent ? `Agente: ${deal.agent.first_name} ${deal.agent.last_name}` : 'Seleccionar'
  });
  const [errors, setErrors] = useState(defaultDeal);
  const [typingTimeout, setTypingTimeout] = useState();

  useEffect(() => {
    if (dealSuccess) {
      toggleEditDeal();
      dispatch(clearNewDeal());
    }
  }, [dealSuccess, toggleEditDeal, dispatch]);

  const handleInputChange = (e) => {
    e.preventDefault();
    const input = e.target;
    const { name } = input;
    let { value } = input;
    if (name === 'amount') {
      value = value.replace(/[^\d.]/g, '');
      input.value = value;
    }
    setNewDeal({ ...newDeal, [name]: value });
  };

  const handleValidation = () => {
    let formIsValid = true;
    const formErrors = { ...defaultDeal };
    if (newDeal.name === '') {
      formIsValid = false;
      formErrors.name = "Nombre no puede estar vacio";
    }
    if (newDeal.name.length > 100) {
      formIsValid = false;
      formErrors.name = "Nombre no puede tener mas de 100 caracteres";
    }

    setErrors(formErrors);
    return formIsValid;
  };

  const closeDealModal = () => {
    setErrors(defaultDeal);
    setNewDeal(defaultDeal);
    toggleEditDeal();
  };

  const handleUpdateDeal = async (e) => {
    const el = e.target;
    el.disabled = true;
    if (handleValidation()) {
      const { name, amount, customerId, agentId } = newDeal;
      const dealBody = {
        deal_id: deal.id,
        name,
        amount,
        retailer_user_id: agentId,
        customer_id: customerId,
        funnel_step_id: columnWebId
      };
      dispatch(updateFunnelStepDeal(dealBody));
      reloadDeals();
    } else {
      el.disabled = false;
    }
  };

  const getOptions = (inputValue, callback) => {
    if (typingTimeout) clearTimeout(typingTimeout);
    const timeout = setTimeout(async () => {
      const endpoint = `/api/v1/customers/search_customers?text=${inputValue}`;
      try {
        const customersResponse = await fetch(endpoint, { credentials: "same-origin" });
        const { customers } = await customersResponse.json();
        const options = mapOptionsToValues(customers, 'selectedCustomer');
        callback(options);
      } catch (error) {
        callback([]);
      }
    }, 500);
    setTypingTimeout(timeout);
  };

  const getAgentOptions = (inputValue, callback) => {
    if (typingTimeout) clearTimeout(typingTimeout);
    const timeout = setTimeout(async () => {
      const endpoint = `/api/v1/retailer_users?search=${inputValue}`;
      try {
        const agentsResponse = await fetch(endpoint, { credentials: "same-origin" });
        const { agents } = await agentsResponse.json();
        const options = mapOptionsToValues(agents, 'selectedAgent');
        callback(options);
      } catch (error) {
        callback([]);
      }
    }, 500);
    setTypingTimeout(timeout);
  };

  const createSelectLabel = (option) => (
    <div>
      <p className="m-0">
        <b>
          {
            option.first_name
              ? `${option.first_name || ''} ${option.last_name || ''}`
              : option.whatsapp_name || ''
          }
        </b>
      </p>
      {option.email && <p className="m-0">{option.email}</p>}
      {option.phone && <p className="m-0">{option.phone}</p>}
    </div>
  );

  const createSelectedOptionTag = (option) => (
    option.first_name && option.last_name
      ? `${option.first_name} ${option.last_name}`
      : option.first_name || option.whatsapp_name || option.phone || 'Vacío'
  );

  const mapOptionsToValues = (options, selected) => (
    options.map((option) => ({
      value: option.id,
      label: createSelectLabel(option),
      [selected]: createSelectedOptionTag(option)
    }))
  );

  const handleSelect = ({ value, selectedCustomer }) => setNewDeal(
    {
      ...newDeal,
      customerId: value,
      selectedCustomer
    }
  );

  const handleSelectAgent = ({ value, selectedAgent }) => setNewDeal(
    {
      ...newDeal,
      agentId: value,
      selectedAgent: `Agente: ${selectedAgent}`
    }
  );

  return (
    <Modal
      isOpen={isOpen}
      style={modalCustomStyles(false)}
      ariaHideApp={false}
    >
      <div className="d-flex justify-content-between">
        <div>
          <p className="font-weight-bold font-gray-dark fs-24">Editar negocio</p>
        </div>
        <div>
          <a className="px-8" type="button" onClick={() => closeDealModal()}>
            <CloseIcon className="fill-dark" />
          </a>
        </div>
      </div>

      <div className="row">
        <div className="mb-20 col-sm-12">
          <input
            value={newDeal.name}
            onChange={handleInputChange}
            className="mercately-input"
            placeholder="Nombre del negocio"
            name="name"
          />
          <span className="funnel-input-error">{errors.name}</span>
        </div>
        <div className="mb-20 col-sm-12">
          <AsyncSelect
            clearable
            isSearchable
            defaultOptions
            menuPortalTarget={document.body}
            menuShouldBlockScroll={false}
            captureMenuScroll={false}
            loadOptions={getOptions}
            onChange={handleSelect}
            placeholder={newDeal.selectedCustomer || 'Seleccionar'}
            noOptionsMessage={() => "Cliente no encontrado"}
            value={null}
            styles={customStyles}
          />
        </div>
        <div className="mb-20 col-sm-12">
          <input
            value={newDeal.amount}
            onChange={handleInputChange}
            className="mercately-input"
            placeholder="Monto de la negociación"
            name="amount"
          />
          <span className="funnel-input-error">{errors.amount}</span>
        </div>
        <div className="mb-20 col-sm-12">
          <AsyncSelect
            clearable
            isSearchable
            defaultOptions
            menuPortalTarget={document.body}
            menuShouldBlockScroll={false}
            captureMenuScroll={false}
            loadOptions={getAgentOptions}
            onChange={handleSelectAgent}
            placeholder={newDeal.selectedAgent || 'Seleccionar'}
            noOptionsMessage={() => "Agente no encontrado"}
            value={null}
            styles={customStyles}
          />
        </div>
        <div className="col text-center">
          <button type="button" className="py-5 px-15 funnel-btn btn--cta" onClick={handleUpdateDeal}>Guardar</button>
        </div>
      </div>
    </Modal>
  );
};

export default DealEdit;
