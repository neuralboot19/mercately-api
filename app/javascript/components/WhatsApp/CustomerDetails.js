import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchCustomer, updateCustomer } from "../../actions/actions";
import EditableField from '../chat/shared/EditableField'
import SelectableField from '../chat/shared/SelectableField'
import EcFlag from 'images/flags/ecuador.png'


var is_updated = false;
const csrfToken = document.querySelector('[name=csrf-token]').content

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
      is_updated = true
      this.props.fetchCustomer(this.props.customerDetails.id)
    } else {
      if (this.state.customer.id !== this.props.customer.id){
        this.setState({ customer: this.props.customer})
      } else {
        is_updated = false
      }
    }
  }

  handleInputChange = (evt, name) => {
    let current_customer = this.state.customer
    current_customer[name] = evt.target.value
    this.setState({customer: current_customer});
  }

  handlesubmit = () => {
    let customer = this.state.customer
    this.props.updateCustomer(customer.id, this.getCustomerInfo() , csrfToken)
  }

  handleSelectChange = (option) => {
    let current_customer = this.state.customer
    current_customer['id_type'] = option.value
    this.setState({customer: current_customer}, () => {
      this.handlesubmit();
    })
  }

  getCustomerInfo = () => {
    let customer = this.state.customer
    return {
      customer: {
        first_name: customer.first_name,
        last_name: customer.last_name,
        email: customer.email, 
        id_type: customer.id_type,
        id_number: customer.id_number,
        address: customer.address,
        city: customer.city,
        state: customer.state
      }
    };
  }

  render() {
    let customer = this.state.customer
    return (
      <div className="customer_sidebar">
        <div className="customer_box">
          <p>
            {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.phone}`}
            <a href={window.location.href.replace('whatsapp_chats', `customers/${customer.web_id}/edit`)} target="_blank">
              <i className="fs-18 mt-4 mr-4 f-right fas fa-external-link-alt"></i>
            </a>
          </p>
        </div>
        <div className="customer_details">
          <div className="details_holder">
            <span>Detalles</span>
          </div>
          <div>
            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-user editable_name" />
              <p className="label inline-block">Nombres</p>
            </div>
            { Object.keys(this.state.customer).length != 0   && (
              <div> 
                <EditableField 
                  handleInputChange={this.handleInputChange}
                  content={this.state.customer.first_name}
                  handlesubmit={this.handlesubmit}
                  targetName='first_name'
                  placeholder="Nombre"
                />
                <br />
                <EditableField 
                 handleInputChange={this.handleInputChange}
                 content={this.state.customer.last_name}
                 handlesubmit={this.handlesubmit}
                 targetName='last_name'
                 placeholder="Apellido"
               />
              </div>
             )}
          </div>
          <div>
            <div>
              <i className="fs-18 mt-4 mr-4 fab fa-whatsapp-square editable_phone"/>
              <p className="label inline-block">Teléfono:</p>
            </div>
            <div><img className="number_flag" src={EcFlag} />  {customer.phone}</div>
          </div>
          <div>
            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-envelope-square editable_email" />
              <p className="label inline-block">Email:</p>
            </div>
            { Object.keys(this.state.customer).length != 0   && (
               <EditableField 
                 handleInputChange={this.handleInputChange}
                 content={this.state.customer.email}
                 handlesubmit={this.handlesubmit}
                 targetName='email'
                 placeholder="Email"
               />
             )}
          </div>
          <div>
            
            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-address-card editable_card_id" />
              <p className="label inline-block">Identificación:</p>
            </div>

            <SelectableField 
              selected={customer.id_type}
              handleSelectChange={this.handleSelectChange}
            />

            <EditableField 
              handleInputChange={this.handleInputChange}
              content={this.state.customer.id_number}
              handlesubmit={this.handlesubmit}
              targetName='id_number'
              placeholder="Identificación"
            />

          </div>
          <div>

            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-map-marked-alt editable_map" />
              <p className="label inline-block">Dirección:</p>
            </div>

            { Object.keys(this.state.customer).length != 0   && (
              <div>
                <EditableField 
                  handleInputChange={this.handleInputChange}
                  content={this.state.customer.address}
                  handlesubmit={this.handlesubmit}
                  targetName='address'
                  placeholder="Dirección"
                />
                <br />
                <EditableField 
                  handleInputChange={this.handleInputChange}
                  content={this.state.customer.city}
                  handlesubmit={this.handlesubmit}
                  targetName='city'
                  placeholder="Ciudad"
                />
                <br />
                <EditableField 
                  handleInputChange={this.handleInputChange}
                  content={this.state.customer.state}
                  handlesubmit={this.handlesubmit}
                  targetName='state'
                  placeholder="Provincia/Estado"
                />
               </div>
             )}


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
    },
    updateCustomer: (id, body, token) => {
      dispatch(updateCustomer(id, body, token));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
) (CustomerDetails);

