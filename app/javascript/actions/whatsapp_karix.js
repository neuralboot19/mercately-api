/* Customers */
export const fetchWhatsAppCustomers = (page = 1, params, offset) => {
  let endpoint = `/api/v1/karix_whatsapp_customers?page=${page}&offset=${offset}`;

  if (params !== null && params !== undefined) {
    endpoint += `&${$.param(params)}`
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
      data => {
        if (data.status && data.status == 401)
          dispatch({ type: 'UNAUTHORIZED_SEND_MESSAGE', data })
        else
          dispatch({ type: 'SET_SEND_MESSAGE', data })
      },
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

export const setWhatsAppMessageAsRead = (id, body, token) => {
  const endpoint = `/api/v1/whatsapp_update_message_read/${id}`;
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
  const endpoint = `/api/v1/whatsapp_templates?page=${page}`;
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

export const changeCustomerAgent = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/assign_agent`;
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
      data => dispatch({ type: 'CHANGE_CUSTOMER_AGENT', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};

export const getWhatsAppFastAnswers = (page = 1, params) => {
  let endpoint = `/api/v1/fast_answers_for_whatsapp?page=${page}`;

  if (params !== '' && params !== undefined) {
    endpoint += `&search=${params}`
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
        data => dispatch({ type: "SET_WHATSAPP_FAST_ANSWERS", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const setNoRead = (customer_id, token, chatService='whatsapp') => {
  const endpoint = `/api/v1/whatsapp_unread_chat/${customer_id}`;
  const csrf_token = token
  return dispatch => {
    fetch(endpoint, {
      method: "PATCH",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrf_token,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
      },
      body: JSON.stringify({chat_service: chatService})
    }).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};

export const fetchTags = (id) => {
  let endpoint = `/api/v1/customers/${id}/selectable_tags`;

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
        data => dispatch({ type: "SET_TAGS", data }),
        err => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
};

export const createCustomerTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/add_customer_tag`;
  const csrf_token = token;
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
      data => dispatch({ type: 'SET_CREATE_CUSTOMER_TAG', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};

export const removeCustomerTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/remove_customer_tag`;
  const csrf_token = token;
  return dispatch => {
    fetch(endpoint, {
      method: "DELETE",
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
      data => dispatch({ type: 'SET_REMOVE_CUSTOMER_TAG', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};

export const createTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/add_tag`;
  const csrf_token = token;
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
      data => dispatch({ type: 'SET_CREATE_TAG', data }),
      err => dispatch({ type: 'LOAD_DATA_FAILURE', err })
    ).catch((error) => {
        if (error.response)
          alert(error.response);
        else
          alert("An unexpected error occurred.");
      });
  };
};
