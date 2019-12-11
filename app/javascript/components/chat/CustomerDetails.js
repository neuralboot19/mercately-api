import React, { Component } from "react";

class CustomerDetails extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0
    };
  }

  render() {
    let customer = this.props.customerDetails
    return (
      <div className="customer_sidebar">
        <div className="customer_box">
          <p>
            {customer.first_name} {customer.last_name}
            <i className="fs-18 mt-4 mr-4 f-right fas fa-external-link-alt"></i>
          </p>
        </div>
        <div className="customer_details">
          <div className="details_holder">
            <span>Detalles</span>
          </div>
          <div>
            <p className="label">Teléfono:</p>
            <i className="fs-18 mt-4 mr-4 fab fa-whatsapp-square"><span className="tag">+593996779124</span></i>
          </div>
          <div>
            <p className="label">Email:</p>
            <i className="fs-18 mt-4 mr-4 fas fa-envelope-square"><span className="tag">henry2992@hotmail.com</span></i>
          </div>
          <div>
            <p className="label">Facebook:</p>
            <i className="fs-18 mt-4 mr-4 fab fa-facebook-square"><span className="tag">henry2992@hotmail.com</span></i>
          </div>
        </div>
        <div className="customer_details">
          <div className="details_holder">
            <span>Detalles</span>
          </div>
          <div>
            <p className="label">Teléfono:</p>
            <i className="fs-18 mt-4 mr-4 fab fa-whatsapp-square"><span className="tag">+593996779124</span></i>
          </div>
          <div>
            <p className="label">Email:</p>
            <i className="fs-18 mt-4 mr-4 fas fa-envelope-square"><span className="tag">henry2992@hotmail.com</span></i>
          </div>
          <div>
            <p className="label">Facebook:</p>
            <i className="fs-18 mt-4 mr-4 fab fa-facebook-square"><span className="tag">henry2992@hotmail.com</span></i>
          </div>
        </div>
      </div>
    )
  }
}

export default CustomerDetails;
