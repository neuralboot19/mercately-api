let initialState = {
  customers: [],
  messages: [],
  total_pages: 0,
  total_customers: 0
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_CURRENT_USER':
      return {
        ...state,
        currentUser: action.response.data.user,
      }
    case 'SET_CUSTOMER':
      console.log(action)
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
    default:
      return state;
  }
}

export default reducer;
