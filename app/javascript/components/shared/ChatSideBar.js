import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import moment from 'moment';
// eslint-disable-next-line import/no-unresolved
import Loader from 'images/dashboard/loader.jpg';
import { fetchCustomers } from "../../actions/actions";
import { fetchWhatsAppCustomers } from "../../actions/whatsapp_karix";
import ChatFilter from './ChatFilter';
import ChatSelector from './ChatSelector';

class ChatSideBar extends Component {
  constructor(props) {
    super(props);
    this.state = {
      page: 1,
      customers: [],
      shouldUpdate: true,
      searchString: '',
      order: 'received_desc',
      agent: 'all',
      type: 'all',
      tag: 'all',
      filter: {
        searchString: '',
        order: 'received_desc',
        type: 'all',
        agent: 'all',
        tag: 'all'
      }
    };

    this.last_customers_offset = 0;
  }

  findCustomerInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id === id
    ))
  )

  handleLoadMore = () => {
    if (this.props.total_customers > this.state.page
      && this.state.customers.length !== this.last_customers_offset
    ) {
      this.setState((prevState) => {
        const page = prevState.page + 1;
        if (this.props.chatType === "facebook") {
          this.props.fetchCustomers(page, prevState.filter, prevState.customers.length);
        }
        if (this.props.chatType === "whatsapp") {
          this.props.fetchWhatsAppCustomers(page, prevState.filter, prevState.customers.length);
        }
        this.last_customers_offset = prevState.customers.length;
        return { page };
      });
    }
  }

  removeFromArray = (arr, index) => {
    arr.splice(index, 1);
    return arr;
  }

  updateCustomerList = (data) => {
    const { customer } = data.customer;
    const { customers } = this.state;
    const index = this.findCustomerInArray(customers, customer.id);
    let customerList = customers;

    if (index !== -1 && data.remove_only) {
      customerList = this.removeFromArray(customerList, index);
    }

    if (!data.remove_only) {
      if (this.props.chatType === 'whatsapp') {
        this.props.setActiveChatBot(customer);
      }
      customerList = this.insertCustomer(customerList, customer, index);
    }

    this.props.setRemovedCustomerInfo(data);
    this.setState({
      customers: customerList
    });
  }

  findInsertPosition = (arr, date) => (
    arr.findIndex((el) => (
      moment(el.recent_message_date) <= moment(date)
    ))
  )

  insertCustomer = (customerList, customer, index) => {
    if (index === -1) {
      if (customerList.length === 0) {
        customerList.unshift(customer);
        return customerList;
      }

      if (customerList[customerList.length - 1].recent_message_date < customer.recent_message_date) {
        const position = this.findInsertPosition(customerList, customer.recent_message_date);

        if (position !== -1) {
          customerList.splice(position, 0, customer);
        }
      }
    } else if (customerList[index].recent_message_date !== customer.recent_message_date) {
      // eslint-disable-next-line no-param-reassign
      customerList = this.removeFromArray(customerList, index);
      customerList.unshift(customer);
    } else {
      // eslint-disable-next-line no-param-reassign
      customerList[index] = customer;
    }
    return customerList;
  }

  handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const el = e.target;
    const style = window.getComputedStyle(el, null);
    // eslint-disable-next-line radix
    const scrollHeight = parseInt(style.getPropertyValue("height"));
    if (el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      this.handleLoadMore();
    }
  }

  handleChatSearch = (e) => {
    e.persist();
    let value;
    this.setState((prevState) => {
      const { filter } = prevState;
      value = e.target.value;
      filter.searchString = value;
      return {
        searchString: value,
        filter
      };
    });
  }

  handleKeyPress = (event) => {
    if (event.key === "Enter") {
      this.setState({
        shouldUpdate: true
      }, () => {
        this.applySearch();
      });
    }
  }

  handleChatOrdering = (event) => {
    if (event.target.value !== this.state.order) {
      const order = event.target.value;
      const { filter } = this.state;
      filter.order = order;
      this.setState({
        order,
        filter
      }, () => this.applySearch());
    }
  }

  handleAddOptionToFilter = (by) => {
    let type = null;
    let agent = null;
    let tag = null;
    const { filter } = this.state;

    if (by === 'type') {
      type = event.target.value;
    } else if (by === 'agent') {
      agent = event.target.value;
    } else if (by === 'tag') {
      tag = event.target.value;
    }
    type = type || this.state.type;
    agent = agent || this.state.agent;
    tag = tag || this.state.tag;

    filter.type = type;
    filter.agent = agent;
    filter.tag = tag;

    this.setState({
      type,
      agent,
      tag,
      filter
    }, () => this.applySearch());
  }

  applySearch = () => {
    this.setState((prevState) => ({
      customers: [],
      filter: prevState.filter,
      page: 1
    }), () => {
      localStorage.setItem(`${this.props.storageId}_filter`, JSON.stringify(this.state.filter));
      if (this.props.chatType === 'whatsapp') {
        this.props.fetchWhatsAppCustomers(1, this.state.filter, 0);
      }
      if (this.props.chatType === 'facebook') {
        this.props.fetchCustomers(1, this.state.filter, 0);
      }
    });
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps(newProps) {
    if (newProps.customers !== this.props.customers) {
      const storedFilter = JSON.parse(localStorage.getItem(`${this.props.storageId}_filter`));
      this.setState((prevState) => ({
        customers: prevState.customers.concat(newProps.customers),
        order: storedFilter ? storedFilter.order : prevState.order,
        agent: storedFilter ? storedFilter.agent : prevState.agent,
        type: storedFilter ? storedFilter.type : prevState.type
      }));
    }
  }

  componentDidMount() {
    let filter;
    const storedFilter = JSON.parse(localStorage.getItem(`${this.props.storageId}_filter`));
    if (storedFilter) {
      storedFilter.searchString = '';
      filter = storedFilter;
    } else {
      filter = this.state.filter;
    }

    switch (this.props.chatType) {
      case 'facebook': {
        this.props.fetchCustomers(1, filter, this.state.customers.length);
        // eslint-disable-next-line no-undef
        socket.on('customer_facebook_chat', (data) => this.updateCustomerList(data));
        break;
      }
      case 'whatsapp': {
        this.props.fetchWhatsAppCustomers(1, filter, this.state.customers.length);
        // eslint-disable-next-line no-undef
        socket.on("customer_chat", (data) => this.updateCustomerList(data));
        break;
      }
      default:
        break;
    }
  }

  componentDidUpdate() {
    let filter = {};
    const storedFilter = JSON.parse(localStorage.getItem(`${this.props.storageId}_filter`));
    if (storedFilter) {
      storedFilter.searchString = this.state.searchString;
      filter = storedFilter;
    } else {
      filter = this.state.filter;
    }

    if (this.state.shouldUpdate) {
      this.setState((prevState) => ({
        shouldUpdate: false,
        filter,
        order: storedFilter ? storedFilter.order : prevState.order,
        agent: storedFilter ? storedFilter.agent : prevState.agent,
        type: storedFilter ? storedFilter.type : prevState.type,
        tag: storedFilter ? storedFilter.tag : prevState.tag
      }));
    }
  }

  render() {
    return (
      <div>
        {this.state.shouldUpdate
          ? (
            <div className="chat_loader">
              <img src={Loader} alt="" />
            </div>
          )
          : (
            <div>
              <ChatFilter
                agent={this.state.agent}
                agents={this.props.agents}
                filterTags={this.props.filter_tags}
                handleAddOptionToFilter={this.handleAddOptionToFilter}
                handleChatOrdering={this.handleChatOrdering}
                handleChatSearch={this.handleChatSearch}
                handleKeyPress={this.handleKeyPress}
                order={this.state.order}
                searchString={this.state.searchString}
                tag={this.state.tag}
                type={this.state.type}
              />
              <ChatSelector
                chatType={this.props.chatType}
                currentCustomer={this.props.currentCustomer}
                customers={this.state.customers}
                handleLoadMoreOnScrollToBottom={this.handleLoadMoreOnScrollToBottom}
                handleOpenChat={this.props.handleOpenChat}
              />
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
    agents: state.agents || [],
    filter_tags: state.filter_tags || [],
    allowSendVoice: state.allowSendVoice
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomers: (page = 1, params, offset) => {
      dispatch(fetchCustomers(page, params, offset));
    },
    fetchWhatsAppCustomers: (page = 1, params, offset) => {
      dispatch(fetchWhatsAppCustomers(page, params, offset));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatSideBar));
