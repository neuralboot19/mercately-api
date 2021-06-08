import React from 'react';
import Modal from 'react-modal';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
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

class DealCreate extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: false,
      newDeal: {},
      errors: {
        name: ''
      }
    };

    this.handleInputChange = this.handleInputChange.bind(this);
  }

  static getDerivedStateFromProps(props) {
    if (props.newDealSuccess) {
      props.openCreateDeal();
      props.clearNewDeal();
      return {
        newDeal: {}
      };
    }
    return null;
  }

  handleInputChange = (evt) => {
    evt.preventDefault();
    const { newDeal } = this.state;
    const { value } = event.target;
    newDeal[evt.target.name] = value;
    this.setState(newDeal);
  };

  handleValidation() {
    const { newDeal } = this.state;
    const errors = {};
    let formIsValid = true;

    if (!newDeal.name) {
      formIsValid = false;
      errors.name = "Nombre no puede estar vacio";
    }

    this.setState({ errors });
    return formIsValid;
  }

  closeDealModal = () => {
    this.setState(() => ({
      errors: {},
      newDeal: {
        name: ''
      }
    }),
    () => {
      this.props.openCreateDeal();
    });
  }

  createNewDeal = () => {
    if (this.handleValidation()) {
      const { newDeal } = this.state;
      newDeal.funnel_step_id = this.props.columnId;
      newDeal.retailer_id = this.props.retailerId;
      this.props.createNewDeal(newDeal, this.props.columnWebId);
    }
  }

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        style={customStyles}
        ariaHideApp={false}
      >
        <button type="button" onClick={this.closeDealModal} className="f-right">Cerrar</button>
        <div className="row">
          <h4 className="mb-15">Nuevo negocio</h4>
        </div>
        <div className="row">
          <div className="mb-20 col-xs-12">
            <input
              value={this.state.newDeal.name || ''}
              onChange={this.handleInputChange}
              className="mb-0 custom-input"
              placeholder="Nombre del negocio"
              name="name"
            />
            <span className="funnel-input-error">{this.state.errors.name}</span>
          </div>

          <div className="row">
            <button type="button" className="py-5 px-15 funnel-btn btn--cta" onClick={this.createNewDeal}>Crear negocio</button>
          </div>
        </div>
      </Modal>
    );
  }
}

function mapStateToProps(state) {
  return {
    newDealSuccess: state.newDealSuccess || false
  };
}

function mapDispatch(dispatch) {
  return {
    createNewDeal: (body, column) => {
      dispatch(createNewDeal(body, column));
    },
    clearNewDeal: () => {
      dispatch(clearNewDeal());
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(DealCreate));
