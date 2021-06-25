import React, { useState, useEffect } from 'react';
import Modal from 'react-modal';
import { useDispatch, useSelector } from 'react-redux';
import AsyncSelect from 'react-select/async';
import {
  createNewDeal,
  clearNewDeal
} from '../../../actions/funnels';

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};
const DealCreate = ({
  openCreateDeal,
  columnId,
  retailerId,
  columnWebId,
  isOpen
}) => {
  const dispatch = useDispatch();
  const newDealSuccess = useSelector((state) => state.newDealSuccess) || false;

  const [newDeal, setNewDeal] = useState({
    name: '',
    customerId: undefined,
    selectedCustomer: 'Select'
  });
  const [errors, setErrors] = useState({ name: '' });
  const [typingTimeout, setTypingTimeout] = useState();

  useEffect(() => {
    if (newDealSuccess) {
      openCreateDeal();
      dispatch(clearNewDeal());
    }
  }, [newDealSuccess, openCreateDeal, dispatch]);

  const handleInputChange = (e) => {
    e.preventDefault();
    // const { newDeal } = this.state;
    const { name, value } = e.target;
    setNewDeal({ ...newDeal, [name]: value });
  };

  const handleValidation = () => {
    let formIsValid = true;
    const formErrors = {
      name: ''
    };
    if (!newDeal.name) {
      formIsValid = false;
      formErrors.name = "Nombre no puede estar vacio";
    }

    setErrors(formErrors);
    return formIsValid;
  };

  const closeDealModal = () => {
    setErrors({});
    setNewDeal({
      name: ''
    });
    openCreateDeal();
  };

  const handleCreateNewDeal = async () => {
    if (handleValidation()) {
      const { name, customerId } = newDeal;
      const deal = {
        name,
        customer_id: customerId,
        funnel_step_id: columnId,
        retailer_id: retailerId
      };
      dispatch(createNewDeal(deal, columnWebId));
    }
  };

  const getOptions = (inputValue, callback) => {
    if (typingTimeout) clearTimeout(typingTimeout);
    const timeout = setTimeout(async () => {
      const endpoint = `/api/v1/customers/search_customers?text=${inputValue}`;
      try {
        const customersResponse = await fetch(endpoint, { credentials: "same-origin" });
        const { customers } = await customersResponse.json();
        const options = mapOptionsToValues(customers);
        callback(options);
      } catch (error) {
        callback([]);
      }
    }, 500);
    setTypingTimeout(timeout);
  };

  const createSelectLabel = (option) => (
    <>
      <p>
        <b>
          {
            option.first_name
              ? `${option.first_name || ''} ${option.last_name || ''}`
              : option.whatsapp_name || ''
          }
        </b>
      </p>
      {option.email && <p>{`${option.email}`}</p>}
      {option.phone && <p>{option.phone}</p>}
    </>
  );

  const createSelectedOptionTag = (option) => (
    option.first_name && option.last_name
      ? `${option.first_name} ${option.last_name}`
      : option.first_name || option.whatsapp_name || option.phone || 'Vacío'
  );

  const mapOptionsToValues = (options) => (
    options.map((option) => ({
      value: option.id,
      label: createSelectLabel(option),
      selectedCustomer: createSelectedOptionTag(option)
    }))
  );

  const handleSelect = ({ value, selectedCustomer }) => setNewDeal(
    {
      ...newDeal,
      customerId: value,
      selectedCustomer
    }
  );

  return (
    <Modal
      isOpen={isOpen}
      style={customStyles}
      ariaHideApp={false}
    >
      <button type="button" onClick={closeDealModal} className="f-right">Cerrar</button>
      <div className="row">
        <h4 className="mb-15">Nuevo negocio</h4>
      </div>
      <div className="row">
        <div className="mb-20 col-xs-12">
          <input
            value={newDeal.name}
            onChange={handleInputChange}
            className="mb-0 custom-input async-select-height "
            placeholder="Nombre del negocio"
            name="name"
          />
          <span className="funnel-input-error">{errors.name}</span>
        </div>

        <div className="mb-20 col-xs-12">
          <AsyncSelect
            clearable
            isSearchable
            loadOptions={getOptions}
            defaultOptions
            onChange={handleSelect}
            placeholder={newDeal.selectedCustomer}
            value={null}
          />
        </div>

        <div className="row">
          <button type="button" className="py-5 px-15 funnel-btn btn--cta" onClick={handleCreateNewDeal}>Crear negocio</button>
        </div>
      </div>
    </Modal>
  );
};

export default DealCreate;
