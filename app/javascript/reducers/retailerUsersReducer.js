const initialState = {
  retailer_info: {}
};

const retailerUsersReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_RETAILER_INFO':
      return {
        ...state,
        retailer_info: action.data.current_retailer
      };
    default:
      return state;
  }
};

export default retailerUsersReducer;