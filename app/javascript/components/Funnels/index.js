import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import DealCreate from "./custom/DealCreate";
import FunnelStepDelete from "./custom/FunnelStepDelete";
import FunnelStepCreate from "./custom/FunnelStepCreate";
import Funnel from "./Funnel";

import {
  updateFunnelStep,
  deleteStep
} from '../../actions/funnels';

class Funnels extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isCreateDealOpen: false,
      isDeleteStepOpen: false,
      isCreateStepOpen: false,
      columnWebId: '',
      columnId: '',
      retailerId: ''
    };
  }

  openCreateDeal = (columnId, columnWebId, retailerId) => {
    this.setState((previousState) => ({
      columnWebId,
      columnId,
      retailerId,
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  };

  openDeleteStep = (columnWebId) => {
    this.setState((previousState) => ({
      columnWebId,
      isDeleteStepOpen: !previousState.isDeleteStepOpen
    }));
  }

  openCreateStep = () => {
    this.setState((previousState) => ({
      isCreateStepOpen: !previousState.isCreateStepOpen
    }));
  }

  createDeal = () => {
    this.setState((previousState) => ({
      isCreateDealOpen: !previousState.isCreateDealOpen
    }));
  }

  createStep = (step) => {
    this.setState((previousState) => ({
      isCreateStepOpen: !previousState.isCreateStepOpen
    }),
    () => {
      this.props.createStep(step);
    });
  }

  deleteStep = () => {
    this.setState((previousState) => ({
      isDeleteStepOpen: !previousState.isDeleteStepOpen
    }),
    () => {
      this.props.deleteStep(this.state.columnWebId);
    });
  }

  render() {
    return (
      <div className="funnel_holder">

        <div className="col-xs-12 col-sm-4">
          <h1 className="d-inline index__title">Negociaciones</h1>
          <div className="index__desc">
            Lista de negociaciones
          </div>
          <button type="button" onClick={() => this.openCreateStep()} className="py-5 px-15 funnel-btn btn--cta">
            Añadir etapa de negociación
          </button>
        </div>

        <Funnel
          openCreateDeal={this.openCreateDeal}
          openDeleteStep={this.openDeleteStep}
        />

        {this.state.isCreateDealOpen
          && (
          <DealCreate
            isOpen={this.state.isCreateDealOpen}
            openCreateDeal={this.openCreateDeal}
            createDeal={this.createDeal}
            sendCreateDeal={this.props.sendCreateDeal}
            columnWebId={this.state.columnWebId}
            columnId={this.state.columnId}
            retailerId={this.state.retailerId}
          />
          )}

        {this.state.isDeleteStepOpen
          && (
          <FunnelStepDelete
            isOpen={this.state.isDeleteStepOpen}
            openDeleteStep={this.openDeleteStep}
            deleteStep={this.deleteStep}
          />
          )}

        {this.state.isCreateStepOpen
          && (
          <FunnelStepCreate
            isOpen={this.state.isCreateStepOpen}
            openCreateStep={this.openCreateStep}
          />
          )}

      </div>

    );
  }
}

function mapStateToProps() {
  return {
  };
}

function mapDispatch(dispatch) {
  return {
    updateFunnelStep: (body) => {
      dispatch(updateFunnelStep(body));
    },
    deleteStep: (column) => {
      dispatch(deleteStep(column));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(Funnels));
