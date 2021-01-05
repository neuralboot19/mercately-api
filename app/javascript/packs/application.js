import "core-js/stable";
import "regenerator-runtime/runtime";

import React from 'react';
import ReactDOM from 'react-dom';
import * as Sentry from "@sentry/react";

import configureStore from "../store/configureStore";

import AppRoutes from "../AppRoutes";

const store = configureStore();

document.addEventListener('DOMContentLoaded', () => {
  // eslint-disable-next-line no-undef
  Sentry.init({ dsn: ENV.SENTRY_DSN });
  ReactDOM.render(
    <AppRoutes store={store} />,
    document.getElementById("react_content")
  );
});
