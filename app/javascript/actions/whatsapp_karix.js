/* Customers */
export const fetchWhatsAppCustomers = (page = 1, params) => {
  let endpoint = `/api/v1/karix_whatsapp_customers?page=${page}`;

  if (params !== '' && params !== undefined) {
    endpoint += `&customerSearch=${params}`
  }
  
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
        data => dispatch({ type: "SET_WHATSAPP_CUSTOMERS", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const sendWhatsAppMessage = (body, token) => {
  const endpoint = `/api/v1/karix_send_whatsapp_message`;
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

export const fetchWhatsAppMessages = (id, page = 1) => {
  const endpoint = `/api/v1/karix_whatsapp_customers/${id}/messages?page=${page}`;
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
        data => dispatch({ type: "SET_WHATSAPP_MESSAGES", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const sendWhatsAppImg = (id, body, token) => {
  const endpoint = `/api/v1/karix_whatsapp_send_file/${id}`;
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

export const setWhatsAppMessageAsReaded = (id, body, token) => {
  const endpoint = `/api/v1/karix_whatsapp_update_message_read/${id}`;
  const csrf_token = token
  return dispatch => {
    fetch(endpoint, {
      method: "PUT",
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

export const fetchWhatsAppTemplates = (page = 1) => {
  const endpoint = `/api/v1/karix_whatsapp_templates?page=${page}`;
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
        data => dispatch({ type: "SET_WHATSAPP_TEMPLATES", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};