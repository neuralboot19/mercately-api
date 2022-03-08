import React, { useEffect, useState } from 'react';
import Select from 'react-select';
import { useDispatch, useSelector } from 'react-redux';
import { forEach } from 'lodash';

import customStyles from '../../util/selectStyles';
import { fetchActiveAgentsByRole } from '../../actions/agents';
import { fetchFunnelSteps } from '../../actions/funnels';

const amountConditions = [
  {value: 'eq', label: 'Igual'},
  {value: 'lt', label: 'Menor que'},
  {value: 'gt', label: 'Mayor que'}
]

const FilterFunnelsForm = () => {
  const dispatch = useDispatch();
  const { agents } = useSelector((reduxState) => reduxState.agentsReducer);
  const { searchFunnelsParams } = useSelector((reduxState) => reduxState.funnelsReducer);

  const initialDefaultFilters = {
    amount: '',
    amount_condition: amountConditions[0],
    agent: { value: 'all', label: 'Todos' }
  };

  const [defaultFilters, setDefaultFilters] = useState(initialDefaultFilters);
  const [agentsOptions, setAgentsOptions] = useState([]);

  const formatAgents = () => {
    const data = [initialDefaultFilters.agent];
    forEach(agents, (row) => {
      data.push({ value: row.id, label: `${row.first_name} ${row.last_name}` });
    });
    setAgentsOptions(data);
  };

  useEffect(() => {
    dispatch(fetchActiveAgentsByRole());
  }, [])

  useEffect(() => {
    formatAgents();
  }, [agents]);

  const handleSubmitFilters = (e) => {
    e.preventDefault();
    const filters = {
      amount: defaultFilters.amount,
      amount_condition: defaultFilters.amount_condition.value,
      agent: defaultFilters.agent.value
    };

    dispatch({ type: "SET_FUNNEL_SEARCH_FILTER", filters });
    dispatch(fetchFunnelSteps({...filters, searchText: searchFunnelsParams.searchText}));
  };

  const handleClearFilters = () => {
    setDefaultFilters(initialDefaultFilters)
    dispatch({ type: "CLEAR_FUNNEL_SEARCH_FILTER"})
  }

  const handleInputChange = (e) => {
    e.preventDefault();
    const input = e.target;
    const { name } = input;
    let { value } = input;
    if (name === 'amount') {
      value = value.replace(/[^\d.]/g, '');
      input.value = value;
    }
    setDefaultFilters({ ...defaultFilters, [name]: value });
  };

  const handleAmountConditionSelect = value => setDefaultFilters({
    ...defaultFilters,
    amount_condition: value
  });

  const handleAgentSelect = value => setDefaultFilters({
    ...defaultFilters,
    agent: value
  });

  return (
    <form className="container-fluid-no-padding">
      <div className="row">
        <div className="mb-20 col-12">
          <div className="funnel-filters">
            <label htmlFor="amount" className="form-label">Monto</label>
            <input
              id="amount"
              value={defaultFilters.amount}
              onChange={handleInputChange}
              className="form-control mercately-input filter-funnel-input"
              placeholder="Escribe un monto"
              name="amount"
            />
          </div>
        </div>

        <div className="mb-20 col-12">
          <div className="funnel-filters">
            <Select
              value={defaultFilters.amount_condition}
              menuPortalTarget={document.body}
              components={{
                IndicatorSeparator: () => null
              }}
              placeholder="Igual"
              onChange={handleAmountConditionSelect}
              className="filter-funnel-input"
              styles={customStyles}
              options={amountConditions}
              name="amount_condition"
            />
          </div>
        </div>

        <div className="mb-20 col-12">
          <div className="funnel-filters">
            <label className="form-label">Agente</label>
            <Select
              value={defaultFilters.agent}
              isSearchable
              menuPortalTarget={document.body}
              components={{
                IndicatorSeparator: () => null
              }}
              placeholder="Todos"
              noOptionsMessage={() => "Agente no encontrado"}
              onChange={handleAgentSelect}
              className="filter-funnel-input"
              styles={customStyles}
              options={agentsOptions}
              name="agent"
            />
          </div>
        </div>

        <div className="mb-20 col-12">
          <button type="submit" className="blue-button fz-14 w-100" onClick={handleSubmitFilters} data-dismiss="modal">Aplicar filtros</button>
        </div>
        <div className="mb-20 col-12 text-center funnel-filters">
          <a className="clear-filters" onClick={handleClearFilters}>Limpar</a>
        </div>
      </div>
    </form>
  );
};

export default FilterFunnelsForm;