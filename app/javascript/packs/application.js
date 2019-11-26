import "core-js/stable";
import "regenerator-runtime/runtime";

import React from 'react'
import ReactDOM from 'react-dom'
import { render } from 'react-dom';
import { createStore } from "redux";
import Reducers from './reducers/index';

import Chats from './containers/Chats';
import AppRoutes from "./AppRoutes";

const store = createStore(Reducers);

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <div>
      <Chats/>
      <AppRoutes store={store}/>
    </div>,
    document.getElementById("react_content"),
  )
})
