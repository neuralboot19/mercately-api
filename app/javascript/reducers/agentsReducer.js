const initialState = {
  agents: [],
};

const agentsReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_AGENTS_DATA': {
      return {
        ...state,
        agents: action.data.agents
      }
    }
    default:
      return state;
  }
};

export default agentsReducer;
