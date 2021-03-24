import React from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import { createBrowserHistory } from 'history';

import Chat from './components/chat';
import WhatsAppChat from './components/WhatsApp';
import ContactGroup from './components/ContactGroup';

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
      <Route
        exact
        path="/retailers/:slug/contact_groups/new"
        component={ContactGroup}
      />
      <Route
        exact
        path="/retailers/:slug/contact_groups/:id/edit"
        component={ContactGroup}
      />
    </Router>
  </Provider>
);

export default AppRoutes;
