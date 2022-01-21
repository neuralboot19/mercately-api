import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { useTranslation } from "react-i18next";
import DealCreate from "./custom/DealCreate";
import DealEdit from "./custom/DealEdit";
import FunnelStepCreate from "./custom/FunnelStepCreate";
import Funnel from "./Funnel";

import {
  deleteStep,
  deleteDeal
} from '../../actions/funnels';

const Funnels = () => {
  const dispatch = useDispatch();

  const { t } = useTranslation();

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
    }
  };

  const handleDeleteDeal = (dealId, columnWebId) => {
    const destroy = confirm('¿Estás seguro de eliminar esta negociación?');
    if (destroy) {
      dispatch(deleteDeal(dealId, columnWebId));
    }
  };

  return (
    <div className="container-fluid">
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
        <div className="col-12">
          <hr />
        </div>
      </div>

      <Funnel
        openCreateDeal={openCreateDeal}
        toggleEditDeal={toggleEditDeal}
        deleteStep={handleDeleteStep}
        deleteDeal={handleDeleteDeal}
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
      {state.isEditDealOpen
        && (
        <DealEdit
          isOpen={state.isEditDealOpen}
          toggleEditDeal={toggleEditDeal}
          createDeal={createDeal}
          columnWebId={state.columnWebId}
          deal={state.deal}
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
