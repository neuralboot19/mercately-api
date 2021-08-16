import React, { useEffect, useRef, useState } from 'react';
import { withRouter } from "react-router-dom";
// eslint-disable-next-line import/no-unresolved
import Loader from 'images/dashboard/loader.jpg';
import { useSelector, useDispatch } from "react-redux";
import { fetchCustomers as fetchCustomersAction } from "../../actions/actions";
import { fetchWhatsAppCustomers as fetchWhatsAppCustomersAction } from "../../actions/whatsapp_karix";
import ChatFilter from './ChatFilter';
import ChatSelector from './ChatSelector';
import filterUtil from '../../util/chatFiltersUtil';
import ActiveFilters from './ActiveFilters';

const _ = require('lodash');

const initialState = {
  page: 1,
  customers: [],
  assignedCustomers: [],
  allCustomers: [],
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
  },
  lastCustomerOffset: 0
};

const ChatSideBar = ({
  handleOpenChat,
  currentCustomer,
  chatType,
  setRemovedCustomerInfo,
  storageId,
  setActiveChatBot,
  platform = 'messenger'
}) => {
  const [state, setState] = useState(initialState);
  const [loading, setLoading] = useState(true);
  const [socketData, setSocketData] = useState();
  const isMounted = useRef(false);
  const isMountedForSearch = useRef(false);
  const isMountedForListAssembly = useRef(false);

  const customers = useSelector((reduxState) => reduxState.customers || []);
  const totalPages = useSelector((reduxState) => reduxState.total_customers || 0);
  const agents = useSelector((reduxState) => reduxState.agents || []);
  const filterTags = useSelector((reduxState) => reduxState.filter_tags || []);
  const loadingMoreCustomers = useSelector((reduxState)=> reduxState.loadingMoreCustomers)

  const dispatch = useDispatch();
  const fetchCustomers = () => {
    dispatch(fetchCustomersAction(state.page, state.filter, state.customers.length, platform));
  };
  const fetchWhatsAppCustomers = () => {
    dispatch(fetchWhatsAppCustomersAction(state.page, state.filter, state.customers.length));
  };

  // Initial effect
  useEffect(() => {
    let filter;
    let order;
    let agent;
    let type;
    let tag;
    const storedFilter = JSON.parse(localStorage.getItem(`${storageId}_filter`));
    if (storedFilter) {
      storedFilter.searchString = '';
      filter = storedFilter;
      order = storedFilter.order;
      agent = storedFilter.agent;
      type = storedFilter.type;
      tag = storedFilter.tag;
    } else {
      filter = { ...state.filter };
      order = state.order;
      agent = state.agent;
      type = state.type;
      tag = state.tag;
    }

    const eventHandler = (data) => setSocketData(data);
    // Subscribe to assignation/de-assignation broadcasts
    switch (chatType) {
      case 'facebook': {
        if (platform === 'instagram') {
          // eslint-disable-next-line no-undef
          socket.on('customer_instagram_chat', eventHandler);
        } else {
          // eslint-disable-next-line no-undef
          socket.on('customer_facebook_chat', eventHandler);
        }
        break;
      }
      case 'whatsapp': {
        // eslint-disable-next-line no-undef
        socket.on("customer_chat", eventHandler);
        break;
      }
      default:
        break;
    }
    setState({
      ...state,
      filter,
      order,
      agent,
      type,
      tag
    });
    return () => {
      // unsubscribe from event for preventing memory leaks
      switch (chatType) {
        case 'facebook': {
          if (platform === 'instagram') {
            // eslint-disable-next-line no-undef
            socket.off('customer_instagram_chat', eventHandler);
          } else {
            // eslint-disable-next-line no-undef
            socket.off('customer_facebook_chat', eventHandler);
          }
          break;
        }
        case 'whatsapp': {
          // eslint-disable-next-line no-undef
          socket.off("customer_chat", eventHandler);
          break;
        }
        default:
          break;
      }
    };
  }, []);

  useEffect(() => {
    if (socketData) {
      updateCustomerList(socketData);
    }
  }, [socketData]);

  // Side effect which requests new data from API
  // Fired after updating order, filter, agent, tag and page
  useEffect(() => {
    if (isMountedForSearch.current) {
      applySearch();
    } else {
      isMountedForSearch.current = true;
    }
  }, [state.order, state.filter, state.agent, state.tag, state.page, state.type, state.customerId]);

  // This side effect is fired after changes in redux's customer state, this just appends new customers'
  // pages to local state
  useEffect(() => {
    const newCustomers = [...new Set([...state.customers, ...customers])];
    if (isMounted.current) {
      setLoading(false);
      setState({
        ...state,
        customers: newCustomers,
        lastCustomerOffset: state.customers.length
      });
    } else {
      isMounted.current = true;
    }
  }, [customers]);

  // This side effect assembles the list of customer to be shown
  useEffect(() => {
    if (isMountedForListAssembly.current) {
      const allCustomers = [...new Set([...state.customers, ...state.assignedCustomers])];
      const allCustomersUniq = _.uniqBy(allCustomers, 'id');
      allCustomersUniq.sort(sortCustomers);
      setState({
        ...state,
        allCustomers: allCustomersUniq
      });
    } else {
      isMountedForListAssembly.current = true;
    }
  }, [state.customers, state.assignedCustomers]);

  // Side effect which saves new filter to localStorage
  // Fired on changes over filter state
  useEffect(() => {
    const newFilter = { ...state.filter };
    delete newFilter.customer_id;
    localStorage.setItem(`${storageId}_filter`, JSON.stringify(newFilter));
  }, [state.filter]);

  const sortCustomers = (cust1, cust2) => {
    if (state.order === "received_asc") {
      return Date.parse(cust1.recent_message_date) - Date.parse(cust2.recent_message_date);
    }
    return Date.parse(cust2.recent_message_date) - Date.parse(cust1.recent_message_date);
  };

  const handleLoadMore = () => {
    if (totalPages > state.page
      && state.customers.length !== state.lastCustomerOffset
      && !loadingMoreCustomers
    ) {
      setState({
        ...state,
        page: state.page + 1
      });
    }
  };

  const removeCustomer = (customer) => {
    const assignedCustomers = [...state.assignedCustomers];
    const newCustomers = [...state.customers];
    let index = assignedCustomers.findIndex((cus) => (
      cus.id === customer.id
    ));
    if (index !== -1) {
      assignedCustomers.splice(index, 1);
    } else {
      index = newCustomers.findIndex((cus) => (
        cus.id === customer.id
      ));
      if (index !== -1) {
        newCustomers.splice(index, 1);
      }
    }
    setState({
      ...state,
      customers: newCustomers,
      assignedCustomers
    });
  };

  const insertCustomer = (customer) => {
    // First check if customer already exists in customers list
    const currentCustomers = [...state.customers];
    let index = currentCustomers.findIndex((cus) => (
      cus.id === customer.id
    ));
    if (index === -1) {
      // If element is not in customers list, check on assignedCustomers list
      const assignedCustomers = [...state.assignedCustomers];
      index = assignedCustomers.findIndex((cus) => (
        cus.id === customer.id
      ));
      if (index === -1) {
        // If element is not in customers list, check on assignedCustomers list
        assignedCustomers.push(customer);
        setState({
          ...state,
          assignedCustomers
        });
      } else {
        assignedCustomers.splice(index, 1, customer);
        setState({
          ...state,
          assignedCustomers
        });
      }
    } else {
      currentCustomers.splice(index, 1, customer);
      setState({
        ...state,
        customers: currentCustomers
      });
    }
  };

  /**
   * Called when a 'customer_facebook_chat' or 'customer_chat' event is broadcasted, usually after an assignation
   * @param data customer info
   */
  const updateCustomerList = (data) => {
    const { customer } = data.customer;
    // Check  if event comes from removal
    if (data.remove_only) {
      // First check if customer is in recently assigned ones' list in order to remove from this list
      // so customers list wont be affected.
      // Assigned agents list is usually the shorter one. So we need to search for the item in this list first.
      removeCustomer(customer);
    } else {
      if (!isCustomerOnList(customer) && !filterUtil.checkFilters(customer, state.filter, chatType)) return;

      setActiveChatBot(customer);
      insertCustomer(customer);
    }
    setRemovedCustomerInfo(data);
  };

  const applySearch = () => {
    if (chatType === 'whatsapp') {
      fetchWhatsAppCustomers();
    }
    if (chatType === 'facebook') {
      fetchCustomers();
    }
  };

  const handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const el = e.target;
    const style = window.getComputedStyle(el, null);
    // eslint-disable-next-line radix
    const scrollHeight = parseInt(style.getPropertyValue("height"));
    if (el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      handleLoadMore();
    }
  };

  const handleSearchInputValueChange = (e) => {
    e.preventDefault();
    const { value } = e.target;
    setState({
      ...state,
      searchString: value
    });
  };

  const handleKeyPress = (event) => {
    if (event.key === "Enter") {
      const filter = { ...state.filter };
      filter.searchString = state.searchString;
      setState({
        ...state,
        page: 1,
        customers: [],
        filter,
        assignedCustomers: [],
        allCustomers: []
      });
    }
  };

  const handleChatOrdering = (event) => {
    event.preventDefault();
    if (event.target.value !== state.order) {
      const order = event.target.value;
      const filter = { ...state.filter };
      filter.order = order;
      setState({
        ...state,
        order,
        filter,
        page: 1,
        customers: [],
        assignedCustomers: [],
        allCustomers: []
      });
    }
  };

  const handleAddOptionToFilter = (by) => {
    let type = null;
    let agent = null;
    let tag = null;
    const filter = { ...state.filter };

    if (by === 'type') {
      type = event.target.value;
    } else if (by === 'agent') {
      agent = event.target.value;
    } else if (by === 'tag') {
      tag = event.target.value;
    }
    type = type || state.type;
    agent = agent || state.agent;
    tag = tag || state.tag;

    filter.type = type;
    filter.agent = agent;
    filter.tag = tag;
    delete filter.customer_id;

    setState({
      ...state,
      type,
      agent,
      tag,
      filter,
      page: 1,
      customers: [],
      assignedCustomers: [],
      allCustomers: []
    });
  };

  const applySearchFromAssignation = (customerId) => {
    const filter = {
      ...state.filter,
      ...{
        customer_id: customerId,
        searchString: '',
        order: 'received_desc',
        type: 'all',
        agent: 'all',
        tag: 'all'
      }
    };

    setState({
      ...state,
      filter,
      page: 1,
      customers: []
    });
  };

  const isCustomerOnList = (customer) => {
    let index = state.allCustomers.findIndex((cus) => (
      cus.id === customer.id
    ));

    return index >= 0;
  }

  const filterApplied = () => {
    return state.filter.searchString !== '' || state.filter.agent !== 'all' || state.filter.type !== 'all' ||
      state.filter.tag !== 'all' || state.filter.order !== 'received_desc'
  }

  const cleanFilters = () => {
    setState(initialState);
  }

  if (loading) {
    return (
      <div>
        <div className="chat_loader">
          <img src={Loader} alt="" />
        </div>
      </div>
    );
  }

  return (
    <div>
      <div>
        {filterApplied() ?
          <ActiveFilters
            cleanFilters={cleanFilters}
          /> : ''
        }
        <ChatFilter
          agent={state.agent}
          agents={agents}
          filterTags={filterTags}
          handleAddOptionToFilter={handleAddOptionToFilter}
          handleChatOrdering={handleChatOrdering}
          handleSearchInputValueChange={handleSearchInputValueChange}
          handleKeyPress={handleKeyPress}
          order={state.order}
          searchString={state.searchString}
          tag={state.tag}
          type={state.type}
        />
        <ChatSelector
          chatType={chatType}
          currentCustomer={currentCustomer}
          customers={state.allCustomers}
          applySearchFromAssignation={applySearchFromAssignation}
          handleLoadMoreOnScrollToBottom={handleLoadMoreOnScrollToBottom}
          handleOpenChat={handleOpenChat}
        />
      </div>
    </div>
  );
};

export default withRouter(ChatSideBar);
