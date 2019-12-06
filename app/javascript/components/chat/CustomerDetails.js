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
        <p>{customer.first_name} {customer.last_name}</p>
      </div>
    )
  }
}

export default CustomerDetails;
