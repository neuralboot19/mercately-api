/* Customers */
export const fetchCustomers = (page = 1, params, offset) => {
  let endpoint = `/api/v1/customers?page=${page}&offset=${offset}`;

  if (params !== null && params !== undefined) {
    // eslint-disable-next-line no-undef
    endpoint += `&${$.param(params)}`;
  }

  return (dispatch) => {
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: "SET_CUSTOMERS", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const fetchCustomer = (id) => {
  const endpoint = `/api/v1/customers/${id}`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: "SET_CUSTOMER", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const updateCustomer = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "PUT",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify(body)
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_CUSTOMER', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

/* Messages */

export const fetchMessages = (id, page = 1) => {
  const endpoint = `/api/v1/customers/${id}/messages?page=${page}`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: "SET_MESSAGES", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const sendMessage = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/messages`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify(body)
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_SEND_MESSAGE', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const sendImg = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/messages/imgs`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_SEND_MESSAGE', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const setMessageAsRead = (id, token) => {
  const endpoint = `/api/v1/messages/${id}/read`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: ''
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_SEND_MESSAGE', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const getMessengerFastAnswers = (page = 1, params) => {
  let endpoint = `/api/v1/fast_answers_for_messenger?page=${page}`;

  if (params !== '' && params !== undefined) {
    endpoint += `&search=${params}`;
  }

  return (dispatch) => {
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: "SET_MESSENGER_FAST_ANSWERS", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const getProducts = (page = 1, params) => {
  let endpoint = `/api/v1/products?page=${page}`;

  if (params !== '' && params !== undefined) {
    endpoint += `&search=${params}`;
  }

  return (dispatch) => {
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: "SET_PRODUCTS", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const sendBulkFiles = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/messages/send_bulk_files`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_SEND_MESSAGE', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};
