import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import DealCreate from "./custom/DealCreate";
import FunnelStepDelete from "./custom/FunnelStepDelete";
import FunnelStepCreate from "./custom/FunnelStepCreate";
import Funnel from "./Funnel";

import {
  deleteStep,
  deleteDeal
} from '../../actions/funnels';
import FunnelDealDelete from './custom/FunnelDealDelete';

const Funnels = () => {
  const dispatch = useDispatch();

  const [state, setState] = useState({
    isCreateDealOpen: false,
    isDeleteDealOpen: false,
    isDeleteStepOpen: false,
    isCreateStepOpen: false,
    columnWebId: undefined,
    columnId: '',
    retailerId: '',
    dealId: undefined
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

  const openDeleteStep = (columnWebId) => {
    setState((previousState) => ({
      ...state,
      columnWebId,
      isDeleteStepOpen: !previousState.isDeleteStepOpen
    }));
  };

  const openDeleteDeal = (dealId, columnWebId) => {
    setState((previousState) => ({
      ...state,
      dealId,
      columnWebId,
      isDeleteDealOpen: !previousState.isDeleteDealOpen
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

  const handleDeleteStep = () => {
    setState((previousState) => ({
      ...state,
      isDeleteStepOpen: !previousState.isDeleteStepOpen
    }));
    dispatch(deleteStep(state.columnWebId));
  };

  const handleDeleteDeal = () => {
    setState((previousState) => ({
      ...state,
      isDeleteDealOpen: !previousState.isDeleteDealOpen
    }));
    dispatch(deleteDeal(state.dealId, state.columnWebId));
  };

  return (
    <div className="funnel_holder">

      <div className="col-xs-12 col-sm-4">
        <h1 className="d-inline index__title">Negociaciones</h1>
        <div className="index__desc">
          Lista de negociaciones
        </div>
        <button type="button" onClick={() => openCreateStep()} className="py-5 px-15 funnel-btn btn--cta">
          Añadir etapa de negociación
        </button>
      </div>

      <Funnel
        openCreateDeal={openCreateDeal}
        openDeleteStep={openDeleteStep}
        openDeleteDeal={openDeleteDeal}
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
        />
        )}

      {state.isDeleteStepOpen
        && (
        <FunnelStepDelete
          isOpen={state.isDeleteStepOpen}
          openDeleteStep={openDeleteStep}
          deleteStep={handleDeleteStep}
        />
        )}

      {state.isCreateStepOpen
        && (
        <FunnelStepCreate
          isOpen={state.isCreateStepOpen}
          openCreateStep={openCreateStep}
        />
        )}

      {state.isDeleteDealOpen
        && (
        <FunnelDealDelete
          isOpen={state.isDeleteDealOpen}
          openDeleteDeal={openDeleteDeal}
          deleteDeal={handleDeleteDeal}
        />
        )}

    </div>

  );
};

export default Funnels;
