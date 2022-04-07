import { combineReducers } from 'redux';
import mainReducer from "./mainReducer";
import statsReducer from "./statsReducer";
import agentsReducer from "./agentsReducer";
import funnelsReducer from './funnelsReducer';
import automaticAnswersReducer from './automaticAnswersReducer';
import retailerUsersReducer from './retailerUsersReducer';

const rootReducer = combineReducers({
  mainReducer,
  statsReducer,
  agentsReducer,
  funnelsReducer,
  automaticAnswersReducer,
  retailerUsersReducer
});

export default rootReducer;
