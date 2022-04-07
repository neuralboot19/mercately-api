import { cloneDeep } from "lodash";

const initialState = {
  messages: [],
  total_pages: 0,
  retailer_info: {},
  closeModal: false
};

const automaticAnswersReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_AUTOMATIC_ANSWERS':
      return {
        ...state,
        messages: action.data.automatic_answers,
        total_pages: action.data.total_pages
      };
    case 'CREATE_AUTOMATIC_ANSWER': {
      let updatedData = cloneDeep(state.messages);
      updatedData.unshift(action.data.automatic_answer);

      return {
        ...state,
        messages: updatedData,
        closeModal: true
      };
    }
    case 'UPDATE_AUTOMATIC_ANSWER': {
      return {
        ...state,
        messages: state.messages.map(item => (item.id === action.data.automatic_answer.id ? item = action.data.automatic_answer: item)),
        closeModal: true
      };
    }
    case 'DELETE_AUTOMATIC_ANSWER':
      return {
        ...state,
        messages: state.messages.filter((item) => item.id !== action.data.automatic_answer.id)
      };
    case 'TOGGLE_MODAL':
      return {
        ...state,
        closeModal: action.data.toggle
      };
    default:
      return state;
  }
};

export default automaticAnswersReducer;
