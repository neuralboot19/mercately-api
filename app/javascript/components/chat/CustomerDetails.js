import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchCustomer } from "../../actions/actions";

var is_updated = false;

class CustomerDetails extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      updated: false,
      customer: {},
    };
  }

  componentDidMount() {
    this.props.fetchCustomer(this.props.customerDetails.id)
  }

  componentDidUpdate(prevProps) {
    if (prevProps.customerDetails.id !== this.props.customerDetails.id && !is_updated){
      this.setState({ customer: this.props.customerDetails}, () => {
        is_updated = true
        this.props.fetchCustomer(this.props.customerDetails.id)
      });      
    } else {
      is_updated = false
    }
  }

  render() {
    let customer = this.props.customer
    return (
      <div className="customer_sidebar">
        <div className="customer_box">
          <p>
            {customer.first_name} {customer.last_name}
            <a href={window.location.href.replace('facebook_chats', `customers/${customer.id}/edit`)} target="_blank">
              <i className="fs-18 mt-4 mr-4 f-right fas fa-external-link-alt"></i>
            </a>
          </p>
        </div>
        <div className="customer_details">
          <div className="details_holder">
            <span>Detalles</span>
          </div>
          <div>
            <p className="label">Teléfono:</p>
            <i className="fs-18 mt-4 mr-4 fab fa-whatsapp-square"><span className="tag">{customer.phone}</span></i>
          </div>
          <div>
            <p className="label">Email:</p>
            <i className="fs-18 mt-4 mr-4 fas fa-envelope-square"><span className="tag">{customer.email}</span></i>
          </div>
          <div>
            <p className="label">Identificación:</p>
            <i className="fs-18 mt-4 mr-4 fas fa-address-card"><span className="tag">{customer.id_number}</span></i>
          </div>
          <div>
            <p className="label">Dirección:</p>
            <i className="fs-18 mt-4 mr-4 fas fa-map-marked-alt">
              <span className="tag">
                {customer.address == 0 || customer.address == null ? '' : `${customer.address}, `}
                {customer.city == 0 || customer.city == null ? '' : `${customer.city}, `}
                {customer.state}&nbsp;
                {customer.zip_code}
              </span>
            </i>
          </div>
        </div>
      </div>
    )
  }
}


function mapState(state) {
  return {
    customer: state.customer || {},
    updated: state.updated || false
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomer: (id) => {
      dispatch(fetchCustomer(id));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
) (CustomerDetails);

