import React, { Component } from "react";

class CustomerDetails extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentCustomer: 0
    };
  }

  render() {
    return (
      <div className="customer_sidebar">
        Heil!
      </div>
    )
  }
}

export default CustomerDetails;
