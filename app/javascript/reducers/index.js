let initialState = {
  customers: [],
  messages: [],
  total_pages: 0,
  total_customers: 0,
  errorSendMessageStatus: null,
  errorSendMessageText: null
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_CURRENT_USER':
      return {
        ...state,
        currentUser: action.response.data.user,
      }
    case 'SET_CUSTOMER':
      return {
        ...state,
        customer: action.data.customer,
        errors: action.data.errors,
        tags: action.data.tags
      }
    case 'SET_CUSTOMERS':
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        filter_tags: action.data.filter_tags
      }
    case 'SET_MESSAGES':
      var balance_error = { status: null, message: null };

      if (action.data.balance_error_info)
        balance_error = action.data.balance_error_info

      return {
        ...state,
        messages: action.data.messages,
        agent_list: action.data.agent_list,
        total_pages: action.data.total_pages,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        errorSendMessageStatus: balance_error.status,
        errorSendMessageText: balance_error.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date,
        customerId: action.data.customer_id,
        filter_tags: action.data.filter_tags
      }
    case 'SET_SEND_MESSAGE':
      return {
        ...state,
        message: action.data.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date
      }
    case 'SET_WHATSAPP_CUSTOMERS':
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        filter_tags: action.data.filter_tags
      }
    case 'SET_WHATSAPP_MESSAGES':
      var balance_error = { status: null, message: null };

      if (action.data.balance_error_info)
        balance_error = action.data.balance_error_info

      return {
        ...state,
        messages: action.data.messages,
        total_pages: action.data.total_pages,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        handle_message_events: action.data.handle_message_events,
        errorSendMessageStatus: balance_error.status,
        errorSendMessageText: balance_error.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date,
        customerId: action.data.customer_id,
        filter_tags: action.data.filter_tags
      }
    case 'SET_WHATSAPP_TEMPLATES':
      return {
        ...state,
        templates: action.data.templates,
        total_template_pages: action.data.total_pages
      }
    case 'CHANGE_CUSTOMER_AGENT':
      return {
        ...state,
        status: action.data.status,
        message: action.data.message
      }
    case 'UNAUTHORIZED_SEND_MESSAGE':
      return {
        ...state,
        errorSendMessageStatus: action.data.status,
        errorSendMessageText: action.data.message,
      }
    case 'SET_WHATSAPP_FAST_ANSWERS':
      return {
        ...state,
        fast_answers: action.data.templates.data,
        total_pages: action.data.total_pages
      }
    case 'SET_MESSENGER_FAST_ANSWERS':
      return {
        ...state,
        fast_answers: action.data.templates.data,
        total_pages: action.data.total_pages
      }
    case 'SET_TAGS':
      return {
        ...state,
        tags: action.data.tags
      }
    case 'SET_CREATE_CUSTOMER_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags
      }
    case 'SET_REMOVE_CUSTOMER_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags
      }
    case 'SET_CREATE_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags,
        filter_tags: action.data.filter_tags
      }
    case 'SET_PRODUCTS':
      return {
        ...state,
        products: action.data.products.data,
        total_pages: action.data.total_pages
      }
    case 'SET_CHAT_BOT':
      return {
        ...state,
        customer: action.data.customer
      }
    default:
      return state;
  }
}

export default reducer;
