import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useTranslation } from "react-i18next";
import DealCreate from "./custom/DealCreate";
import DealEdit from "./custom/DealEdit";
import FunnelStepCreate from "./custom/FunnelStepCreate";
import Funnel from "./Funnel";
import SearchInput from '../shared/SearchInput';
import { fetchFunnelSteps } from '../../actions/funnels';
import SidebarModal from '../shared/SidebarModal';
import FilterFunnelsForm from './FilterFunnelsForm';
import FilterIcon from 'images/filter.svg';

import {
  deleteStep,
  deleteDeal
} from '../../actions/funnels';

const Funnels = () => {
  const dispatch = useDispatch();

  const { t } = useTranslation();

  const { searchFunnelsParams } = useSelector((reduxState) => reduxState.funnelsReducer);

  const [state, setState] = useState({
    isCreateDealOpen: false,
    isEditDealOpen: false,
    isCreateStepOpen: false,
    columnWebId: undefined,
    columnId: '',
    retailerId: '',
    dealId: undefined,
    deal: {}
  });

  const openCreateDeal = (columnId, columnWebId, retailerId) => {
    setState((previousState) => ({
      ...state,
      columnWebId,
      columnId,
      retailerId,
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  };

  const toggleEditDeal = (deal, columnWebId) => {
    setState((previousState) => ({
      ...state,
      columnWebId,
      deal,
      isEditDealOpen: !previousState.isEditDealOpen
    }));
  };

  const openCreateStep = () => {
    setState((previousState) => ({
      ...state,
      isCreateStepOpen: !previousState.isCreateStepOpen
    }));
  };

  const createDeal = () => {
    setState((previousState) => ({
      ...state,
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  };

  const handleDeleteStep = (columnWebId) => {
    const destroy = confirm('¿Estás seguro de eliminar esta etapa de negociación? (se borrarán todas las negociaciones adentro de esta etapa)');
    if (destroy) {
      dispatch({ type: 'CLEAR_FUNNELS' });
      dispatch(deleteStep(columnWebId));
      reloadDeals();
    }
  };

  const handleDeleteDeal = (dealId, columnWebId) => {
    const destroy = confirm('¿Estás seguro de eliminar esta negociación?');
    if (destroy) {
      dispatch(deleteDeal(dealId, columnWebId));
      reloadDeals();
    }
  };

  const applySearch = (searchText) => {
    const params = {searchText: searchText};
    dispatch({ type: "SET_FUNNEL_SEARCH_PARAMS", params })

    const filters = {
      searchText: searchText,
      amount: searchFunnelsParams.amount,
      amount_condition: searchFunnelsParams.amount_condition,
      agent: searchFunnelsParams.agent
    };

    dispatch(fetchFunnelSteps(filters));
  }

  const reloadDeals = () => {
    const filters = {
      searchText: searchFunnelsParams.searchText,
      amount: searchFunnelsParams.amount,
      amount_condition: searchFunnelsParams.amount_condition,
      agent: searchFunnelsParams.agent
    };

    setTimeout(() => {
      dispatch(fetchFunnelSteps(filters));
    }, 200);
  }

  return (
    <div className="container-fluid">
      <SidebarModal id="funnel_filters" title="Filtros">
        <FilterFunnelsForm />
      </SidebarModal>
      
      <div className="row">
        <div className="col-xs-12 col-sm-4">
          <h1 className="d-inline funnels__title">{t('funnelsTitle')}</h1>
        </div>

        <div className="col-sm-8">
          <div className="d-flex justify-content-end">
            <button type="button" onClick={() => openCreateStep()} className="btn-btn btn-submit btn-primary-style">
              Añadir etapa de negociación
            </button>
          </div>
        </div>
      </div>

      <div className="row mt-42 funnles">
        <SearchInput applySearch={applySearch} placeholder={'Buscar por nombre negociación o cliente'} />
        <button className="white-button my-24px my-md-0 w-100 w-sm-auto ml-10" type="button" data-toggle="modal" data-target="#funnel_filters">
          Filtros
          <img src={FilterIcon} className="pl-8" />
        </button>
      </div>

      <div className="row mt-38">
        <div className="col-12">
          <hr />
        </div>
      </div>

      <Funnel
        openCreateDeal={openCreateDeal}
        toggleEditDeal={toggleEditDeal}
        deleteStep={handleDeleteStep}
        deleteDeal={handleDeleteDeal}
        searchFunnelsParams={searchFunnelsParams}
      />

      {state.isCreateDealOpen
        && (
        <DealCreate
          isOpen={state.isCreateDealOpen}
          openCreateDeal={openCreateDeal}
          createDeal={createDeal}
          columnWebId={state.columnWebId}
          columnId={state.columnId}
          retailerId={state.retailerId}
          reloadDeals={reloadDeals}
        />
        )}
      {state.isEditDealOpen
        && (
        <DealEdit
          isOpen={state.isEditDealOpen}
          toggleEditDeal={toggleEditDeal}
          createDeal={createDeal}
          columnWebId={state.columnWebId}
          deal={state.deal}
          reloadDeals={reloadDeals}
        />
        )}
      {state.isCreateStepOpen
        && (
        <FunnelStepCreate
          isOpen={state.isCreateStepOpen}
          openCreateStep={openCreateStep}
        />
        )}
    </div>
  );
};

export default Funnels;
