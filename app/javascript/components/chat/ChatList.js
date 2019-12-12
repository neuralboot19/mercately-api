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
      page: 1,
      customers: []
    };
  }

  findCustomerInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  handleLoadMore = () => {
    if (this.props.total_customers > this.state.page) {
      let page = ++this.state.page;
      this.setState({ page: page })
      this.props.fetchCustomers(page);
    }
  }

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

  handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    let style = window.getComputedStyle(el, null);
    let scrollHeight = parseInt(style.getPropertyValue("height"));
    if(el.scrollTop + scrollHeight >= el.scrollHeight) {
      this.handleLoadMore();
    }
  }

  componentWillReceiveProps(newProps){
    if (newProps.customers != this.props.customers) {
      this.setState({
        customers: this.state.customers.concat(newProps.customers)
      })
    }
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
      <div className="chat__selector" onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
        {this.state.customers.map((customer) =>
        <ChatListUser
          key={customer.id}
          currentCustomer={this.props.currentCustomer}
          customer={customer}
          handleOpenChat={this.props.handleOpenChat}
        />)}
      </div>
    );
  }
}

function mapState(state) {
  return {
    customers: state.customers || [],
    total_customers: state.total_customers || 0,
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomers: (page = 1) => {
      dispatch(fetchCustomers(page));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatList));
