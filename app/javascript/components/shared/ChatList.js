import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchCustomers } from "../../actions/actions";
import ChatListUser from './ChatListUser';
import { fetchWhatsAppCustomers } from "../../actions/whatsapp_karix";


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

      if (this.props.chatType == "facebook"){
        this.props.fetchCustomers(page);
      }
      if (this.props.chatType == "whatsapp"){
        this.props.fetchWhatsAppCustomers(page);
      }
    }
  }

  removeFromArray = (arr, index) => {
    arr.splice(index, 1);
    return arr
  }

  updateCustomerList = (customer) => {
    var customers = this.props.customers;
    var index = this.findCustomerInArray(customers, customer.id);
    if (index !== -1) {
      var customerList = this.removeFromArray(customers, index);
    } else {
      var customerList = customers;
    }
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
    if (this.props.chatType == "facebook"){
      this.props.fetchCustomers();
      socket.on("customer_facebook_chat", data => this.updateList(data));
    }
    if (this.props.chatType == "whatsapp"){
      this.props.fetchWhatsAppCustomers();
      socket.on("customer_chat", data => this.updateList(data));
    }
  }

  componentDidUpdate() {
    if (_shouldUpdate) {
      _shouldUpdate = false;
      this.setState({
        customers: this.props.customers
      })
    }
  }

  updateList = (data) => {
    var customer = data.customer.customer;
    if (customer.id != this.props.currentCustomer) {
      if (this.props.chatType == "facebook"){
        customer["unread_message?"] = true;
      }
      if (this.props.chatType == "whatsapp"){
        customer["karix_unread_message?"] = true;
      }
    }
    this.updateCustomerList(customer);
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
          chatType={this.props.chatType}
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
    },
    fetchWhatsAppCustomers: (page = 1) => {
      dispatch(fetchWhatsAppCustomers(page));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatList));
