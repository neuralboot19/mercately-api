import React, { useState, useEffect } from 'react';
import Select from 'react-select';

import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from  '../icons/CloseIcon';
import Modal from 'react-modal';
import { useDispatch, useSelector } from 'react-redux';
import { forEach, find } from 'lodash';
import {
  createNewDeal,
  updateFunnelStepDeal,
  clearNewDeal
} from '../../actions/funnels';
import reactSelectCustomStyles from '../../util/reactSelectCustomStyles';

const DealModal = ({
  customer,
  funnelSteps,
  isDealModalOpen,
  toggleDealModal,
  dealSelected,
  agents,
  getCustomerDeals
}) => {
  const dispatch = useDispatch();
  const dealSuccess = useSelector((reduxState) => reduxState.mainReducer.newDealSuccess) || false;
  const currentRetailerUser = useSelector((reduxState) => reduxState.mainReducer.currentRetailerUser) || {};

  const [newDeal, setNewDeal] = useState({
    name: dealSelected ? dealSelected.name : '',
    amount: dealSelected ? (dealSelected.amount ? dealSelected.amount : '') : '',
    selectedFunnelStep: null,
    selectedAgent: null
  });
  const [errors, setErrors] = useState({name: '', funnelStep: ''});
  const [funnelStepsOptions, setFunnelStepsOptions] = useState([]);
  const [agentsOptions, setAgentsOptions] = useState([]);

  useEffect(() => {
    if (dealSuccess) {
      getCustomerDeals();
      toggleDealModal();
      dispatch(clearNewDeal());
    }
  }, [dealSuccess, toggleDealModal, dispatch]);

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
    let isValidForm = true;

    const formErrors = {};
    if (!newDeal.name) {
      isValidForm = false;
      formErrors.name = "Nombre no puede estar vacio";
    }

    if (newDeal.name.length > 100) {
      isValidForm = false;
      formErrors.name = "Nombre no puede tener mas de 100 caracteres";
    }

    if (!newDeal.selectedFunnelStep) {
      isValidForm = false;
      formErrors.funnelStep = "Seleccione estado de negociación";
    }

    setErrors(formErrors);
    return isValidForm;
  };

  const handleSelectFunnelStep = value => setNewDeal({
    ...newDeal,
    selectedFunnelStep: value
  });

  const handleSelectAgent = value => setNewDeal({
    ...newDeal,
    selectedAgent: value
  });

  const mapOptionsToValues = (options) => (
    options.map((option) => ({
      value: option.id,
      label: option.first_name ? `Agente: ${option.first_name || ''} ${option.last_name || ''}` : option.whatsapp_name || ''
    }))
  );

  const mapSelectOptions = () => {
    let _funnelSteps = [];
    let funnelStep;

    forEach(funnelSteps.columnOrder, (element) => {
      funnelStep = find(funnelSteps.columns, (value, key) => {
        if (key == element) {
          return value;
        }
      });

      if (funnelStep) _funnelSteps.push({value: funnelStep.id, label: funnelStep.title, internal_id: funnelStep.internal_id});
    });

    let _agents = mapOptionsToValues(agents);

    if (dealSelected) {
      setNewDeal({
        ...newDeal,
        selectedFunnelStep: find(_funnelSteps, {internal_id: dealSelected.funnel_step_id}),
        selectedAgent: find(_agents, {value: dealSelected.retailer_user_id})
      });
    }
    else if (customer.assigned_agent && customer.assigned_agent.id) {
      setNewDeal({
        ...newDeal,
        selectedAgent: find(_agents, {value: customer.assigned_agent.id})
      });
    }
    else if (currentRetailerUser) {
      setNewDeal({
        ...newDeal,
        selectedAgent: find(_agents, {value: currentRetailerUser.id})
      });
    }

    setFunnelStepsOptions(_funnelSteps);
    setAgentsOptions(_agents);
  }

  useEffect(() => {
    mapSelectOptions();
  }, []);

  const customerFullName = () => {
    return customer.first_name? `${customer.first_name || ''} ${customer.last_name || ''}` : customer.whatsapp_name || ''
  }

  const submitDeal = evt => {
    evt.preventDefault();

    if (!handleValidation()) {
      return;
    }

    const { name, amount, selectedFunnelStep, selectedAgent } = newDeal;

    let deal = {
      name,
      amount,
      customer_id: customer.id,
      retailer_user_id: selectedAgent.value
    };

    if (dealSelected) {
      deal['deal_id'] = dealSelected.web_id;
      deal['funnel_step_id'] = selectedFunnelStep.value;
      dispatch(updateFunnelStepDeal(deal));
    }
    else {
      deal['funnel_step_id'] = selectedFunnelStep.internal_id;
      deal['retailer_id'] = ENV.CURRENT_RETAILER_ID;
      dispatch(createNewDeal(deal, selectedFunnelStep.value));
    }
  }

  return (
    <Modal
      isOpen={isDealModalOpen}
      style={modalCustomStyles(false)}
      ariaHideApp={false}>
      <div className="bd-example-modal-lg">
        <div className="modal-dialog modal-lg custom-modal-dialog">
          <form onSubmit={submitDeal}>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title font-weight-bold font-gray-dark fs-24">{dealSelected ? 'Editar negocio' : 'Nuevo negocio'}</h5>
                <button type="button" className="close" aria-label="Close" onClick={() => toggleDealModal()}>
                  <CloseIcon className="fill-dark" />
                </button>
              </div>

              <div className="modal-body">
                <div className="form-container">
                  <div className="row">
                    <div className="col-md-12 pl-0 pr-0">
                      <div className="form-group">
                        <input value={newDeal.name}
                              name="name"
                              className="mercately-input"
                              placeholder="Nombre del negocio"
                              onChange={handleInputChange} />
                        <span className="funnel-input-error">{errors.name}</span>
                      </div>
                    </div>
                  </div>

                  <div className="row">
                    <div className="col-md-12 pl-0 pr-0">
                      <div className="form-group">
                        <input defaultValue={customerFullName()}
                              className="mercately-input"
                              name="customer"
                              disabled={true}
                              readOnly />
                      </div>
                    </div>
                  </div>

                  <div className="row">
                    <div className="col-md-12 pl-0 pr-0">
                      <div className="form-group">
                        <input value={newDeal.amount}
                              name="amount"
                              className="mercately-input"
                              placeholder="Monto de la negociación"
                              onChange={handleInputChange} />
                      </div>
                    </div>
                  </div>

                  <div className="row">
                    <div className="col-md-12 pl-0 pr-0">
                      <div className="form-group">
                        <Select options={agentsOptions}
                                value={newDeal.selectedAgent}
                                className="mercately-input mercately-input-select"
                                placeholder='Agente'
                                styles={reactSelectCustomStyles}
                                onChange={handleSelectAgent}
                                components={{
                                  IndicatorSeparator: () => null
                                }} />
                      </div>
                    </div>
                  </div>

                  <div className="row">
                    <div className="col-md-12 pl-0 pr-0">
                      <div className="form-group">
                        <Select options={funnelStepsOptions}
                                value={newDeal.selectedFunnelStep}
                                className="mercately-input mercately-input-select"
                                placeholder='Estado negociación'
                                styles={reactSelectCustomStyles}
                                onChange={handleSelectFunnelStep}
                                components={{
                                  IndicatorSeparator: () => null
                                }} />
                        <span className="funnel-input-error">{errors.funnelStep}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div className="text-center">
                <a className="cancel-link mr-30" onClick={() => toggleDealModal()}>Cancelar</a>
                <button type="submit" className="btn py-5 px-15 funnel-btn btn--cta">{dealSelected ? 'Actualizar negocio' : 'Crear negocio'}</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </Modal>
  );
};

export default DealModal;
