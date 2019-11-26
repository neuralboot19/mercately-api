import React from "react";
// import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import ChatMessages from './containers/ChatMessages';
import Whatsapp from './components/Whatsapp';

const AppRoutes = ({ store }) => (
  <Provider store={store}>
    <Router>
      <Route
        exact
        path="/retailers/:slug/whatsapp"
        component={Whatsapp}
      />
      <Route
        exact
        path="/retailers/:slug/facebook_chats"
        component={ChatMessages}
      />
    </Router>
  </Provider>
)

export default AppRoutes;
