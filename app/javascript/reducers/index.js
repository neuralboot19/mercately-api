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
        customer: action.data.customer
      }
    case 'SET_CUSTOMERS':
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers
      }
    case 'SET_MESSAGES':
      return {
        ...state,
        messages: action.data.messages,
        total_pages: action.data.total_pages
      }
    case 'SET_SEND_MESSAGE':
      return {
        ...state,
        message: action.data.message
      }
    case 'SET_WHATSAPP_CUSTOMERS':
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers
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
        errorSendMessageStatus: balance_error.status,
        errorSendMessageText: balance_error.message
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
    default:
      return state;
  }
}

export default reducer;
