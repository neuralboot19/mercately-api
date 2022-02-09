import React from 'react';
import Modal from 'react-modal';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import {
  createStep,
  clearNewStep
} from '../../../actions/funnels';

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
    height: '50vh',
    width: '50%'
  }
};

class FunnelStepCreate extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      newStep: {
        name: ''
      },
      errors: {
        name: ''
      }
    };
  }

  static getDerivedStateFromProps(props) {
    if (props.newStepSuccess) {
      props.openCreateStep();
      props.clearNewStep();
      return {
        newStep: {}
      };
    }
    return null;
  }

  handleInputChange = (evt) => {
    evt.preventDefault();
    const { newStep } = this.state;
    const { value } = event.target;
    newStep[evt.target.name] = value;
    this.setState(newStep);
  };

  handleValidation() {
    const { newStep } = this.state;
    const errors = {};
    let formIsValid = true;

    if (!newStep.name) {
      formIsValid = false;
      errors.name = "Nombre no puede estar vacio";
    }

    if (newStep.name.length > 40) {
      formIsValid = false;
      errors.name = "Nombre no puede tener mas de 40 caracteres";
    }

    this.setState({ errors });
    return formIsValid;
  }

  createNewStep = (e) => {
    const el = e.target;
    el.disabled = true;
    if (this.handleValidation()) {
      this.props.createStep(this.state.newStep);
    } else {
      el.disabled = false;
    }
  }

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        style={customStyles}
        ariaHideApp={false}
      >
        <button type="button" onClick={this.props.openCreateStep} className="f-right btn btn--no-border c-red">
          <i className="fas fa-times mr-5" />
          Cerrar
        </button>
        <h4 className="my-0">Crear etapa de negocio</h4>
        <div className="mb-15">
          <p className="my-0 index__desc">Las etapas del embudo representan los pasos de tu proceso de ventas</p>
        </div>
        <div className="mb-20 col-xs-12">
          <input
            value={this.state.newStep.name}
            onChange={this.handleInputChange}
            className="mercately-input"
            placeholder="Nombre de la etapa"
            name="name"
          />
          <span className="funnel-input-error">{this.state.errors.name}</span>
        </div>

        <div className="text-center">
          <button type="button" className="py-5 px-15 funnel-btn btn--cta" onClick={this.createNewStep}>Crear Etapa</button>
        </div>

      </Modal>
    );
  }
}

function mapStateToProps({  mainReducer: state }) {
  return {
    newStepSuccess: state.newStepSuccess || false
  };
}

function mapDispatch(dispatch) {
  return {
    createStep: (body) => {
      dispatch(createStep(body));
    },
    clearNewStep: () => {
      dispatch(clearNewStep());
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(FunnelStepCreate));
