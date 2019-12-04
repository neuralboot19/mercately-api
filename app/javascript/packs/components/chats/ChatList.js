import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchCustomers } from "../../actions/actions";

import ChatListUser from './ChatListUser';

var _shouldUpdate = true;
class ChatList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      customers: []
    };
  }

  findCustomerInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  removeFromArray = (arr, index) => {
    arr.splice(index, 1);
    return arr
  }

  updateCustomerList = (customer) => {
    var customers = this.props.customers;
    var index = this.findCustomerInArray(customers, customer.id);
    var customerList = this.removeFromArray(customers, index);
    customerList.unshift(customer);
    this.setState({
      customers: customerList
    });
  }

  componentDidMount() {
    this.props.fetchCustomers();

    App.cable.subscriptions.create(
      { channel: 'CustomersChannel' },
      {
        received: data => {
          this.updateCustomerList(data.customer);
        }
      }
    );
  }

  componentDidUpdate() {
    if (_shouldUpdate) {
      _shouldUpdate = false;
      this.setState({
        customers: this.props.customers
      })
    }
  }

  render() {
    return (
      <div className="chat__selector">
        {this.state.customers.map((customer) => <ChatListUser key={customer.id} customer={customer} handleOpenChat={this.props.handleOpenChat}/>)}
      </div>
    );
  }
}

function mapState(state) {
  return {
    customers: state.customers || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomers: () => {
      dispatch(fetchCustomers());
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatList));
