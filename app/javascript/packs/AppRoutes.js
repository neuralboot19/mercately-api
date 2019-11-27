import React from "react";
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import configureStore from "./store/configureStore";

import Chats from './containers/Chats';

const store = configureStore();
const AppRoutes = ({ store }) => (
  <Provider store={store}>
    <Router>
      <Route
        exact
        path="/retailers/:slug/facebook_chats"
        component={Chats}
      />
    </Router>
  </Provider>
)

export default AppRoutes;
