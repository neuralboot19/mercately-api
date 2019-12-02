import "core-js/stable";
import "regenerator-runtime/runtime";

import React from 'react'
import ReactDOM from 'react-dom'
import configureStore from "./store/configureStore";

import AppRoutes from "./AppRoutes";

const store = configureStore();

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <AppRoutes store={store}/>,
    document.getElementById("react_content"),
  )
})
