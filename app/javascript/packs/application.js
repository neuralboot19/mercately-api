import "core-js/stable";
import "regenerator-runtime/runtime";

import React from 'react'
import ReactDOM from 'react-dom'
import configureStore from "./store/configureStore";
import { ActionCableProvider } from 'react-actioncable-provider';

import AppRoutes from "./AppRoutes";

const store = configureStore();

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <ActionCableProvider url="ws://localhost:3000/cable">
      <AppRoutes store={store}/>
    </ActionCableProvider>,
    document.getElementById("react_content"),
  )
})
