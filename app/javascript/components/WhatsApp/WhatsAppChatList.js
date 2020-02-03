import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchWhatsAppCustomers } from "../../actions/whatsapp_karix";


var _shouldUpdate = true;
class WhatsAppChatList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      page: 1,
      customers: []
    };
  }

  handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    let style = window.getComputedStyle(el, null);
    let scrollHeight = parseInt(style.getPropertyValue("height"));

    if (el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      this.handleLoadMore();
    }
  }

  handleLoadMore = () => {
    if (this.props.total_customers > this.state.page) {
      let page = ++this.state.page;
      this.setState({ page: page })
      this.props.fetchWhatsAppCustomers(page);
    }
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
    var customers = this.state.customers;
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

  componentDidMount() {
    this.props.fetchWhatsAppCustomers();

    App.cable.subscriptions.create(
      { channel: 'KarixCustomersChannel' },
      {
        received: data => {
          var customer = data.customer;
          if (customer.id != this.props.currentCustomer) {
            customer["karix_unread_message?"] = true;
          }
          this.updateCustomerList(customer);
        }
      }
    );
  }

  componentWillReceiveProps(newProps){
    if (newProps.customers != this.props.customers) {
      this.setState({
        customers: this.state.customers.concat(newProps.customers)
      })
    }
  }

  render() {
    return (
      <div className="chat__selector" onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
        {this.state.customers.map((customer) =>

          <div className={`profile fs-14 box ${this.props.currentCustomer == customer.id ? 'border border--secondary' : 'border border--transparent'}`} onClick={() => this.props.handleOpenChat(customer)}>
            <div className="profile__data row">
              <div className="img__profile col-xs-2 p-0">
                <div className="rounded-circle mw-100" >
                </div>
              </div>
              <div className="col-xs-10">
                <div className="profile__name">
                  {`${customer.first_name && customer.last_name  ? `${customer.first_name} ${customer.last_name}` : customer.phone}`}
                </div>
                <div className={customer["karix_unread_message?"] ? 'fw-bold' : ''}>
                  {moment(customer.recent_message_date).locale('es').fromNow()}
                </div>
              </div>
            </div>
          </div>
        )}
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
    fetchWhatsAppCustomers: (page = 1) => {
      dispatch(fetchWhatsAppCustomers(page));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(WhatsAppChatList));
