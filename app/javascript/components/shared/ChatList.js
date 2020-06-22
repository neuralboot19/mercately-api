import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchCustomers } from "../../actions/actions";
import ChatListUser from './ChatListUser';
import { fetchWhatsAppCustomers } from "../../actions/whatsapp_karix";
import Loader from 'images/dashboard/loader.jpg'

class ChatList extends Component {
  constructor(props) {
    super(props)
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

    this.last_customers_offset = 0
  }

  findCustomerInArray = (arr, id) => (
    arr.findIndex((el) => (
      el.id == id
    ))
  )

  handleLoadMore = () => {
    if (this.props.total_customers > this.state.page  &&
        this.state.customers.length != this.last_customers_offset
       ) {
      let page = ++this.state.page;
      this.setState({ page: page })

      if (this.props.chatType == "facebook"){
        this.props.fetchCustomers(page, this.state.filter, this.state.customers.length);
      }
      if (this.props.chatType == "whatsapp"){
        this.props.fetchWhatsAppCustomers(page, this.state.filter, this.state.customers.length);
      }

      this.last_customers_offset = this.state.customers.length;
    }
  }

  removeFromArray = (arr, index) => {
    arr.splice(index, 1);
    return arr
  }

  updateCustomerList = (data) => {
    var customer = data.customer.customer;
    var customers = this.state.customers;
    var index = this.findCustomerInArray(customers, customer.id);
    var customerList = customers;

    if (index !== -1 && data.remove_only) {
      customerList = this.removeFromArray(customerList, index);
    }

    if (!data.remove_only) {
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
      if (customerList.length == 0) {
        customerList.unshift(customer);
        return customerList;
      }

      if (customerList[customerList.length - 1].recent_message_date < customer.recent_message_date) {
        var position = this.findInsertPosition(customerList, customer.recent_message_date);

        if (position !== -1) {
          customerList.splice(position, 0, customer);
        }
      }
    } else {
      if (customerList[index].recent_message_date != customer.recent_message_date) {
        customerList = this.removeFromArray(customerList, index);
        customerList.unshift(customer);
      } else {
        customerList[index] = customer;
      }
    }

    return customerList;
  }

  handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    let style = window.getComputedStyle(el, null);
    let scrollHeight = parseInt(style.getPropertyValue("height"));
    if(el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      this.handleLoadMore();
    }
  }

  handleChatSearch = (e) => {
    let value;
    let filter = this.state.filter;

    value = e.target.value;
    filter['searchString'] = value;
    this.setState({
      searchString: value,
      filter: filter
    });
  }

  handleKeyPress = (event) => {
    if (event.key === "Enter") {
      this.setState({
        shouldUpdate: true,
      }, () => {
        this.applySearch();
      })
    }
  }

  handleChatOrdering = (event) => {
    if (event.target.value !== this.state.order) {
      let order = event.target.value;
      let filter = this.state.filter;

      filter['order'] = order;

      this.setState({
        order: order,
        filter: filter
      }, () => this.applySearch() );
    }
  }

  handleAddOptionToFilter = (by) => {
    let type = null, agent = null, tag = null;
    let filter = this.state.filter;

    if (by === 'type')
      type = event.target.value;
    else if (by == 'agent')
      agent = event.target.value;
    else if (by == 'tag')
      tag = event.target.value;

    type = type || this.state.type;
    agent = agent || this.state.agent;
    tag = tag || this.state.tag;

    filter['type'] = type;
    filter['agent'] = agent;
    filter['tag'] = tag;

    this.setState({
      type: type,
      agent: agent,
      tag: tag,
      filter: filter
    }, () => this.applySearch() );
  }

  applySearch = () => {
    this.setState({
      customers: [],
      filter: this.state.filter,
      page: 1
    }, () => {
      localStorage.setItem(this.props.storageId + '_filter', JSON.stringify(this.state.filter));
      if (this.props.chatType == 'whatsapp'){
        this.props.fetchWhatsAppCustomers(1, this.state.filter, 0);
      }
      if (this.props.chatType == 'facebook'){
        this.props.fetchCustomers(1, this.state.filter, 0);
      }
    })
  }

  componentWillReceiveProps(newProps){
    if (newProps.customers != this.props.customers) {
      let storedFilter = JSON.parse(localStorage.getItem(this.props.storageId + '_filter'));
      this.setState({
        customers: this.state.customers.concat(newProps.customers),
        order: storedFilter ? storedFilter['order'] :  this.state.order,
        agent: storedFilter ? storedFilter['agent'] :  this.state.agent,
        type: storedFilter ? storedFilter['type'] : this.state.type
      })
    }
  }

  componentDidMount() {
    let filter = {};
    let storedFilter = JSON.parse(localStorage.getItem(this.props.storageId + '_filter'));
    if (storedFilter) {
      storedFilter['searchString'] = '';
      filter = storedFilter;
    } else {
      filter = this.state.filter;
    }

    if (this.props.chatType == "facebook"){
      this.props.fetchCustomers(1, filter, this.state.customers.length);
      socket.on("customer_facebook_chat", data => this.updateList(data));
    }
    if (this.props.chatType == "whatsapp"){
      this.props.fetchWhatsAppCustomers(1, filter, this.state.customers.length);
      socket.on("customer_chat", data => this.updateList(data));
    }
  }

  componentDidUpdate() {
    let filter = {};
    let storedFilter = JSON.parse(localStorage.getItem(this.props.storageId + '_filter'));
    if (storedFilter) {
      storedFilter['searchString'] = this.state.searchString;
      filter = storedFilter;
    } else {
      filter = this.state.filter;
    }

    if (this.state.shouldUpdate) {
      this.setState({
        shouldUpdate: false,
        filter: filter,
        order: storedFilter ? storedFilter['order'] :  this.state.order,
        agent: storedFilter ? storedFilter['agent'] :  this.state.agent,
        type: storedFilter ? storedFilter['type'] : this.state.type,
        tag: storedFilter ? storedFilter['tag'] : this.state.tag
      })
    }
  }

  updateList = (data) => {
    var customer = data.customer.customer;
    this.updateCustomerList(data);
  }

  render() {
    return (
      <div>
        {this.state.shouldUpdate ?
          <div className="chat_loader"><img src={Loader} /></div>
        :
          <div>
            <div className='chat__control'>
              <input
                type="text"
                value={this.state.searchString}
                onChange={(e) => this.handleChatSearch(e)}
                placeholder="Buscar"
                style={{
                  width: "95%",
                  borderRadius: "5px",
                  marginBottom: "5px",
                  border: "1px solid #ddd",
                  padding: "8px",
                }}
                className="form-control"
                onKeyPress={(e) => this.handleKeyPress(e)}
              />

              <div
                style={{
                  margin: "0",
                }}
              >
                <p
                  style={{
                    display: "inline-block",
                    margin: "0",
                    marginBottom: "5px",
                    width: "100%"
                  }}
                >Filtrar por:&nbsp;&nbsp;
                  <select
                    style={{
                      float: 'right',
                      fontSize: '12px',
                      maxWidth: "200px"
                    }}
                    id="type"
                    value={this.state.type}
                    onChange={(e) => this.handleAddOptionToFilter('type')}
                  >
                    <option value='all'>Todos</option>
                    <option value='no_read'>No leídos</option>
                    <option value='read'>Leídos</option>
                  </select>
                </p>
                <p
                  style={{
                    display: "inline-block",
                    margin: "0",
                    marginBottom: "5px",
                    width: "100%"
                  }}
                >Agente:&nbsp;&nbsp;
                  <select
                    style={{
                      float: 'right',
                      fontSize: '12px',
                      maxWidth: "200px"
                    }}
                    id="agents"
                    value={this.state.agent}
                    onChange={(e) => this.handleAddOptionToFilter('agent')}
                  >
                    <option value="all">Todos</option>
                    <option value="not_assigned">No asignados</option>
                    {this.props.agents.map((agent, index) => (
                      <option value={agent.id} key={index}>{`${agent.first_name && agent.last_name ? agent.first_name + ' ' + agent.last_name : agent.email}`}</option>
                    ))}
                  </select>
                </p>
                <p
                  style={{
                    display: "inline-block",
                    margin: "0",
                    marginBottom: "5px",
                    width: "100%"
                  }}
                  >Etiquetas:&nbsp;&nbsp;
                  <select
                    style={{
                      float: 'right',
                      fontSize: '12px',
                      maxWidth: "200px"
                    }}
                    id="tags"
                    value={this.state.tag}
                    onChange={(e) => this.handleAddOptionToFilter('tag')}
                  >
                    <option value="all">Todos</option>
                    {this.props.filter_tags.map((tag, index) => (
                      <option value={tag.id} key={index}>{tag.tag}</option>
                    ))}
                  </select>
                </p>
                <p
                  style={{
                    display: "inline-block",
                    margin: "0",
                    marginBottom: "5px",
                    width: "100%"
                  }}
                >Ordenar por:&nbsp;&nbsp;
                  <select
                    style={{
                      float: 'right',
                      fontSize: '12px',
                      maxWidth: "200px"
                    }}
                    id="order"
                    value={this.state.order}
                    onChange={(e) => this.handleChatOrdering(e)}
                  >
                    <option value='received_desc'>Reciente - Antíguo</option>
                    <option value='received_asc'>Antíguo - Reciente</option>
                  </select>
                </p>
              </div>
            </div>
            <div className="chat__selector" onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
              {this.state.customers.map((customer, index) =>
              <ChatListUser
                key={index}
                currentCustomer={this.props.currentCustomer}
                customer={customer}
                handleOpenChat={this.props.handleOpenChat}
                chatType={this.props.chatType}
              />)}
            </div>
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
    agents: state.agents || [],
    filter_tags: state.filter_tags || []
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
)(withRouter(ChatList));
