export const fetchContactGroup = (id) => {
  const endpoint = `/api/v1/contact_groups/${id}`;

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
        (data) => dispatch({ type: "SET_CONTACT_GROUP", data }),
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

export const fetchCustomers = (page = 1, params) => {
  let endpoint = `/api/v1/contact_groups/customers?page=${page}`;

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

export const fetchSelectedCustomers = (page = 1, params) => {
  let endpoint = `/api/v1/contact_groups/customers?page=${page}`;

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
        (data) => dispatch({ type: "SET_SELECTED_CUSTOMERS", data }),
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

export const fetchDefaultSelectedCustomers = (id, page = 1, params) => {
  let endpoint = `/api/v1/contact_groups/${id}/selected_customers?page=${page}`;

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
        (data) => dispatch({ type: "SET_SELECTED_CUSTOMER_IDS", data }),
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

export const fetchTags = () => {
  const endpoint = `/api/v1/tags`;

  return (dispatch) => fetch(endpoint, {
    method: "GET",
    credentials: "same-origin",
    headers: {
      Accept: "application/json, text/plain, */*",
      "Content-Type": "application/json"
    }
  })
    .then((res) => res.json())
    .then(
      (data) => dispatch({ type: "SET_TAGS", data }),
      (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
    ).catch((error) => {
      if (error.response) alert(error.response);
      else alert("An unexpected error occurred.");
    });
};

export const createContactGroup = (body, csrfToken) => {
  const endpoint = `/api/v1/contact_groups`;

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
        (data) => {
          if (data.errors) {
            dispatch({ type: 'SET_CONTACT_GROUP_ERRORS', data });
          } else {
            document.location.href = `/retailers/${ENV.SLUG}/contact_groups`;
          }
        },
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

export const updateContactGroup = (id, body, csrfToken) => {
  const endpoint = `/api/v1/contact_groups/${id}`;

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
        (data) => {
          if (data.errors) {
            dispatch({ type: 'SET_CONTACT_GROUP_ERRORS', data });
          } else {
            document.location.href = `/retailers/${ENV.SLUG}/contact_groups`;
          }
        },
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
