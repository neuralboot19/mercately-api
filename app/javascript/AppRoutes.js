import React from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import { createBrowserHistory } from 'history';

import Chat from './components/chat';
import WhatsAppChat from './components/WhatsApp';

const customHistory = createBrowserHistory();

const AppRoutes = ({ store }) => (
  <Provider store={store}>
    <Router history={customHistory}>
      <Route
        exact
        path="/retailers/:slug/facebook_chats"
        component={Chat}
      />
      <Route
        exact
        path="/retailers/:slug/whatsapp_chats"
        component={WhatsAppChat}
      />
    </Router>
  </Provider>
);

export default AppRoutes;
