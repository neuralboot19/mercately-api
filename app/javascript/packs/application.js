import "core-js/stable";
import "regenerator-runtime/runtime";

import React from 'react';
import ReactDOM from 'react-dom';
import * as Sentry from "@sentry/react";

import configureStore from "../store/configureStore";

import AppRoutes from "../AppRoutes";
import '../i18n';

const store = configureStore();

document.addEventListener('DOMContentLoaded', () => {
  Sentry.init({
    // eslint-disable-next-line no-undef
    dsn: ENV.SENTRY_DSN,
    // eslint-disable-next-line no-undef
    environment: ENV.ENVIRONMENT
  });
  ReactDOM.render(
    <AppRoutes store={store} />,
    document.getElementById("react_content")
  );
});
