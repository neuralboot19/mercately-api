import {
  Router,
  Route,
  Switch
} from 'react-router-dom';
import React, { Component } from "react";
import Chat from './components/Chat.js';
class AppRoutes extends Component {
  render() {
    return (
      <div>
        <Switch>
          <Route
            exact
            path="/retailers/:slug/facebook_chats"
            component={Chat}
          />
      </Switch>
      </div>
    )
  }
}
export default AppRoutes;
