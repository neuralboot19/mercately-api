const initialState = {
  searchFunnelsParams: {
    searchText: '',
    amount: '',
    amount_condition: 'eq',
    agent: 'all'
  }
};

const funnelsReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_FUNNEL_SEARCH_PARAMS': {
      return {
        ...state,
        searchFunnelsParams: {
          ...state.searchFunnelsParams,
          searchText: action.params.searchText
        }
      }
    }
    case 'SET_FUNNEL_SEARCH_FILTER': {
      return {
        ...state,
        searchFunnelsParams: {
          ...state.searchFunnelsParams,
          amount: action.filters.amount,
          amount_condition: action.filters.amount_condition,
          agent: action.filters.agent
        }
      }
    }
    case 'CLEAR_FUNNEL_SEARCH_FILTER': {
      return {
        ...state,
        searchFunnelsParams: {
          ...state.searchFunnelsParams,
          amount: '',
          amount_condition: 'eq',
          agent: 'all'
        }
      }
    }
    default:
      return state;
  }
};

export default funnelsReducer;