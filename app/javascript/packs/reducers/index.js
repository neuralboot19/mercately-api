let initialState = {
  currentUser: {}
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_CURRENT_USER':
      return {
        currentUser: action.response.data.user
      }
    default:
      return state;
  }
}

export default reducer;
