let initialState = {
  customers: []
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
        customers: action.response.data.customers
      }
    default:
      return state;
  }
}

export default reducer;
