import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchCustomer, updateCustomer } from "../../actions/actions";
import { fetchTags,
         createCustomerTag,
         removeCustomerTag,
         createTag } from "../../actions/whatsapp_karix";
import EditableField from '../shared/EditableField'
import SelectableField from '../shared/SelectableField'

var is_updated = false;
const csrfToken = document.querySelector('[name=csrf-token]').content

class CustomerDetails extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0,
      updated: false,
      customer: {},
      tags: [],
      newTag: ''
    };
  }

  componentDidMount() {
    this.props.fetchCustomer(this.props.customerDetails.id)
    this.props.fetchTags(this.props.customerDetails.id);
  }

  componentDidUpdate(prevProps) {
    if (prevProps.customerDetails.id !== this.props.customerDetails.id && !is_updated){
      is_updated = true
      this.props.fetchCustomer(this.props.customerDetails.id)
      this.props.fetchTags(this.props.customerDetails.id);
    } else {
      if (this.state.customer.id !== this.props.customer.id || this.state.customer.phone !== this.props.customer.phone){
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

  handleSelectTagChange = (option) => {
    var params = {
      tag_id: option.value,
      chat_service: this.props.chatType == 'facebook_chats' ? 'facebook' : 'whatsapp'
    }

    this.props.createCustomerTag(this.state.customer.id, params, csrfToken);
  }

  removeCustomerTag = (tag) => {
    var params = {
      tag_id: tag.id,
      chat_service: this.props.chatType == 'facebook_chats' ? 'facebook' : 'whatsapp'
    }

    this.props.removeCustomerTag(this.state.customer.id, params, csrfToken);
  }

  onKeyPress = (e) => {
    if(e.which === 13) {
      e.preventDefault();
      if (this.state.newTag.trim() === '') return;

      this.createTag();
    }
  }

  handleNewTagChange = (e) => {
    this.setState({
      [e.target.name]: e.target.value
    })
  }

  createTag = () => {
    var params = {
      tag: this.state.newTag,
      chat_service: this.props.chatType == 'facebook_chats' ? 'facebook' : 'whatsapp'
    }

    this.props.createTag(this.state.customer.id, params, csrfToken);
    this.setState({newTag: ''});
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
        state: customer.state,
        notes: customer.notes,
        phone: customer.phone
      }
    };
  }

  render() {
    let customer = this.state.customer
    return (
      <div className={this.props.onMobile ? "customer_sidebar no-border-left" : "customer_sidebar" }>
        {this.props.onMobile && (
          <div className="c-secondary fs-15 mt-12" onClick={() => this.props.backToChatMessages()}>
            <i className="fas fa-chevron-left c-secondary"></i>&nbsp;&nbsp;volver
          </div>
        )}
        <div className="customer_box">
          <p>
            {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.whatsapp_name ? customer.whatsapp_name : customer.phone}`}
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
            <div>{this.state.customer.emoji_flag}
              <EditableField
                handleInputChange={this.handleInputChange}
                content={this.state.customer.phone}
                handlesubmit={this.handlesubmit}
                targetName='phone'
                placeholder="Teléfono"
              />
            </div>
          </div>
          <div>
            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-envelope-square editable_email" />
              <p className="label inline-block">Email:</p> <small className="validation-msg">{this.props.errors.email}</small>
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

          <div>
            <div>
              <i className="fs-18 mt-4 mr-4 fas fa-tags editable_name" />
              <p className="label inline-block">Etiquetas:</p>
            </div>

            <div>
              <SelectableField
                handleSelectTagChange={this.handleSelectTagChange}
                isTag={true}
                options={this.props.tags}
              />

              <input className="input" type="text" name="newTag" value={this.state.newTag} placeholder="Nueva etiqueta" maxLength="20" onChange={this.handleNewTagChange} onKeyPress={this.onKeyPress} />
            </div>

            <div className="row bottom-xs">
              {this.props.customer.tags && this.props.customer.tags.map((tag, index) => (
                <div key={index} className="customer-saved-tags mt-10">
                  {tag.tag}
                  {<i className="fas fa-times f-right mt-2 cursor-pointer" onClick={() => this.removeCustomerTag(tag)}></i>}
                </div>
              ))}
            </div>
          </div>

          <div>
            <EditableField
              handleInputChange={this.handleInputChange}
              content={this.state.customer.notes}
              handlesubmit={this.handlesubmit}
              targetName='notes'
              placeholder="Notas"
              givenClass='editable-notes'
            />
          </div>


        </div>

        <div className="t-center mt-20">
          {this.state.customer.id &&
            <a href={window.location.href.replace(`${this.props.chatType}`, `orders/new?customer_id=${this.state.customer.id}&from=${this.props.chatType}`)} target="_blank" className="btn btn--cta">
              Generar Venta
            </a>
          }

          {!this.state.customer.id &&
            <a href={window.location.href.replace(`${this.props.chatType}`, `orders/new?first_name=${this.state.customer.first_name}&last_name=${this.state.customer.last_name}&email=${this.state.customer.email}&phone=${this.state.customer.phone}&from=${this.props.chatType}`)} target="_blank" className="btn btn--cta">
              Generar Venta
            </a>
          }
        </div>
      </div>
    )
  }
}


function mapState(state) {
  return {
    customer: state.customer || {},
    updated: state.updated || false,
    errors: state.errors || {},
    tags: state.tags || []
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomer: (id) => {
      dispatch(fetchCustomer(id));
    },
    updateCustomer: (id, body, token) => {
      dispatch(updateCustomer(id, body, token));
    },
    fetchTags: (id) => {
      dispatch(fetchTags(id));
    },
    createCustomerTag: (id, params, token) => {
      dispatch(createCustomerTag(id, params, token));
    },
    removeCustomerTag: (id, params, token) => {
      dispatch(removeCustomerTag(id, params, token));
    },
    createTag: (id, params, token) => {
      dispatch(createTag(id, params, token));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
) (CustomerDetails);

