import React from "react";
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import Chats from './containers/Chats';

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
