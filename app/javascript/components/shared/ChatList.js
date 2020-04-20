import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchCustomers } from "../../actions/actions";
import ChatListUser from './ChatListUser';
import { fetchWhatsAppCustomers } from "../../actions/whatsapp_karix";
import Loader from 'images/dashboard/loader.jpg'


var _shouldUpdate = true;
class ChatList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      page: 1,
      customers: [],
      searchString: '', 
      shouldUpdate: true
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

  updateCustomerList = (data) => {
    var customer = data.customer.customer;
    var customers = this.props.customers;
    var index = this.findCustomerInArray(customers, customer.id);
    if (index !== -1) {
      var customerList = this.removeFromArray(customers, index);
    } else {
      var customerList = customers;
    }

    if (!data.remove_only) {
      customerList.unshift(customer);
    }

    if (this.props.chatType == 'whatsapp') {
      this.props.setRemovedCustomerInfo(data);
    }

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

  handleChatSearch = (e) => {
    let value;
    value = e.target.value;
    this.setState({
      searchString: value,
    });
  }

  handleKeyPress = event => {
    if (event.key === "Enter") {
      this.setState({shouldUpdate: true}, () => { 
        this.applySearch();
      })
    }
  };

  applySearch = () => {
    this.setState({customers: []}, () => {
      if (this.props.chatType == 'whatsapp'){
        this.props.fetchWhatsAppCustomers(1, this.state.searchString);  
      }
      if (this.props.chatType == 'facebook'){
        this.props.fetchCustomers(1, this.state.searchString);
      }
    })
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
    if (this.state.shouldUpdate) {
      this.setState({
        customers: this.props.customers,
        shouldUpdate: false
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
    this.updateCustomerList(data);
  }

  render() {
    return (
      <div>
        {this.state.shouldUpdate ? 
          <div className="chat_loader"><img src={Loader} /></div>
        :
          <div className="chat__selector" onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
            <div >
              <input
                type="text"
                value={this.state.searchString}
                onChange={e =>
                  this.handleChatSearch(e)
                }
                placeholder="Busqueda por email, nombre o número"
                style={{
                  width: "100%",
                  borderRadius: "5px",
                  marginBottom: "20px",
                  border: "1px solid #ddd",
                  padding: "8px 0px",
                }}
                className="form-control"
                onKeyPress={this.handleKeyPress}
              />
            </div>

            {this.state.customers.map((customer) =>
            <ChatListUser
              key={customer.id}
              currentCustomer={this.props.currentCustomer}
              customer={customer}
              handleOpenChat={this.props.handleOpenChat}
              chatType={this.props.chatType}
            />)}
          </div>
        }
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
    fetchCustomers: (page = 1, params) => {
      dispatch(fetchCustomers(page, params));
    },
    fetchWhatsAppCustomers: (page = 1, params) => {
      dispatch(fetchWhatsAppCustomers(page, params));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatList));
