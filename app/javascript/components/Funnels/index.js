import React, { useState } from 'react';
import { connect, useDispatch } from 'react-redux';
import { withRouter } from 'react-router-dom';
import DealCreate from "./custom/DealCreate";
import FunnelStepDelete from "./custom/FunnelStepDelete";
import FunnelStepCreate from "./custom/FunnelStepCreate";
import Funnel from "./Funnel";

import {
  updateFunnelStep,
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
      columnWebId,
      columnId,
      retailerId,
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  };

  const openDeleteStep = (columnWebId) => {
    setState((previousState) => ({
      columnWebId,
      isDeleteStepOpen: !previousState.isDeleteStepOpen
    }));
  };

  const openDeleteDeal = (dealId, columnWebId) => {
    setState((previousState) => ({
      dealId,
      columnWebId,
      isDeleteDealOpen: !previousState.isDeleteDealOpen
    }));
  };

  const openCreateStep = () => {
    setState((previousState) => ({
      isCreateStepOpen: !previousState.isCreateStepOpen
    }));
  };

  const createDeal = () => {
    setState((previousState) => ({
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  };

  const createStep = (step) => {
    setState((previousState) => ({
      isCreateStepOpen: !previousState.isCreateStepOpen
    }),
    () => {
      props.createStep(step);
    });
  };

  const handleDeleteStep = () => {
    setState((previousState) => ({
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

function mapDispatch(dispatch) {
  return {
    updateFunnelStep: (body) => {
      dispatch(updateFunnelStep(body));
    }
  };
}

export default connect(() => {}, mapDispatch)(withRouter(Funnels));
