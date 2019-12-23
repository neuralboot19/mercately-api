/* Customers */
export const fetchCustomers = (page = 1) => {
  const endpoint = `/api/v1/customers?page=${page}`;
  return dispatch =>
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then(res => res.json())
      .then(
        data => dispatch({ type: "SET_CUSTOMERS", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const fetchCustomer = (id) => {
  const endpoint = `/api/v1/customers/${id}`;
  return dispatch =>
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then(res => res.json())
      .then(
        data => dispatch({ type: "SET_CUSTOMER", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const fetchMessages = (id, page = 1) => {
  const endpoint = `/api/v1/customers/${id}/messages?page=${page}`;
  return dispatch =>
    fetch(endpoint, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      }
    })
      .then(res => res.json())
      .then(
        data => dispatch({ type: "SET_MESSAGES", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const sendMessage = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/messages`;
  const csrf_token = token
  return dispatch => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrf_token,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
      },
      body: JSON.stringify(body),
    })
    .then(res => res.json())
    .then(
      data => dispatch({ type: 'SET_SEND_MESSAGE', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};

export const sendImg = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/messages/imgs`;
  const csrf_token = token
  return dispatch => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': csrf_token,
      },
      body: body,
    })
    .then(res => res.json())
    .then(
      data => dispatch({ type: 'SET_SEND_MESSAGE', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};
