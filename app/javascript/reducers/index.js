import { combineReducers } from 'redux';
import mainReducer from "./mainReducer";
import statsReducer from "./statsReducer";
import agentsReducer from "./agentsReducer";
import funnelsReducer from './funnelsReducer';

const rootReducer = combineReducers({
  mainReducer,
  statsReducer,
  agentsReducer,
  funnelsReducer
});

export default rootReducer;
