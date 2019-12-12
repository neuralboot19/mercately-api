import React from "react";
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route, browserHistory, withRouter } from 'react-router-dom';
import { createBrowserHistory } from "history";

import Chat from './components/chat/Chat';

const customHistory = createBrowserHistory();

const AppRoutes = ({ store }) => (
  <Provider store={store}>
    <Router history={customHistory}>
      <Route
        exact
        path="/retailers/:slug/facebook_chats"
        component={Chat}
      />
    </Router>
  </Provider>
)

export default AppRoutes;
