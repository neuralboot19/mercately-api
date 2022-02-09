import { combineReducers } from 'redux';
import mainReducer from "./mainReducer";
import statsReducer from "./statsReducer";
import agentsReducer from "./agentsReducer";

const rootReducer = combineReducers({
  mainReducer,
  statsReducer,
  agentsReducer
});

export default rootReducer;
