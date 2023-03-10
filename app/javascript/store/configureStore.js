import { createStore, applyMiddleware } from "redux";
import thunkMiddleware from "redux-thunk";
import { createLogger } from "redux-logger";
import reducers from "../reducers";

const logger = createLogger({
  level: "info",
  collapsed: false,
  logger: console,
  predicate: (getState, action) => true
});
let middlewares = [thunkMiddleware];
if (process.env.NODE_ENV !== "production") {
  middlewares = [...middlewares, logger];
}
const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
export default function configureStore(initialState) {
  const store = createStoreWithMiddleware(reducers, initialState);
  if (module.hot) {
    // Enable Webpack hot module replacement for reducers
    module.hot.accept("../reducers", () => {
      // eslint-disable-next-line global-require
      const nextRootReducer = require("../reducers");
      store.replaceReducer(nextRootReducer);
    });
  }
  return store;
}
