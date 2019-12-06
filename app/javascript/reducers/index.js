let initialState = {
  customers: [],
  messages: []
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_CURRENT_USER':
      return {
        ...state,
        currentUser: action.response.data.user
      }
    case 'SET_CUSTOMERS':
      return {
        ...state,
        customers: action.data.customers
      }
    case 'SET_MESSAGES':
      return {
        ...state,
        messages: action.data.messages
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