import React from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import { createBrowserHistory } from 'history';
import Chat from './components/chat';
import WhatsAppChat from './components/WhatsApp';
import ContactGroup from './components/ContactGroup';
import Funnels from './components/Funnels';
import MLChat from './components/MLChat';

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
      <Route
        exact
        path="/retailers/:slug/funnels"
        component={Funnels}
      />
      <Route
        exact
        path="/retailers/:slug/mercadolibre_chats"
        component={MLChat}
      />
    </Router>
  </Provider>
);

export default AppRoutes;
