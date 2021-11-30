/* Customers */
import {
  LOAD_DATA_FAILURE, SET_CUSTOMERS, SET_CUSTOMERS_REQUEST,
  SET_MESSAGES, SET_MESSAGES_REQUEST
} from "../actionTypes";

export const fetchCustomers = (page = 1, params, offset, platform = 'messenger') => {
  let endpoint = `/api/v1/customers?page=${page}&offset=${offset}&platform=${platform}`;

  if (params !== null && params !== undefined) {
    // eslint-disable-next-line no-undef
    endpoint += `&${$.param(params)}`;
  }

  return (dispatch) => {
    dispatch({ type: SET_CUSTOMERS_REQUEST });
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
        (data) => dispatch({ type: SET_CUSTOMERS, data }),
        (err) => dispatch({ type: LOAD_DATA_FAILURE, err })
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

export const fetchNotes = (id, platform) => {
  const endpoint = `/api/v1/customers/${id}/notes?platform=${platform}`;
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
        (data) => dispatch({ type: "SET_NOTES", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch(
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      );
  };
};

export const addNote = (body) => (
  (dispatch) => (
    dispatch({ type: "ADD_NOTE", body })
  )
);

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

export const cancelReminder = (reminderId) => {
  const endpoint = `/api/v1/reminders/${reminderId}/cancel`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "PUT",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      }
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

export const fetchMessages = (id, page = 1, platform = 'messenger') => {
  const endpoint = `/api/v1/customers/${id}/messages?page=${page}&platform=${platform}`;
  return (dispatch) => {
    dispatch({ type: SET_MESSAGES_REQUEST });
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
        (data) => dispatch({ type: SET_MESSAGES, data }),
        (err) => dispatch({ type: LOAD_DATA_FAILURE, err })
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const sendMessage = (id, body, token, platform = 'messenger') => {
  const endpoint = `/api/v1/customers/${id}/messages?platform=${platform}`;
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

export const sendImg = (id, body, token, platform = 'messenger') => {
  const endpoint = `/api/v1/customers/${id}/messages/imgs?platform=${platform}`;
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

export const setMessageAsRead = (id, token, platform = 'messenger') => {
  const endpoint = `/api/v1/messages/${id}/read?platform=${platform}`;
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

export const getInstagramFastAnswers = (page = 1, params) => {
  let endpoint = `/api/v1/fast_answers_for_instagram?page=${page}`;

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
        (data) => dispatch({ type: "SET_INSTAGRAM_FAST_ANSWERS", data }),
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

export const sendBulkFiles = (id, body, token, platform = 'messenger') => {
  const endpoint = `/api/v1/customers/${id}/messages/send_bulk_files?platform=${platform}`;
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

/* Custom Fields */
export const fetchCustomerFields = (customerId) => {
  const endpoint = `/api/v1/customers/${customerId}/custom_fields`;
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
        (data) => dispatch({ type: "SET_CUSTOM_FIELDS", data }),
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

export const updateCustomerField = (customerId, id, body, token) => {
  const endpoint = `/api/v1/customers/${customerId}/custom_fields/${id}`;
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
        (data) => dispatch({ type: 'SET_CUSTOM_FIELDS', data }),
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

export const changeChatMessagingState = (body, token) => {
  const endpoint = '/api/v1/change_chat_status';
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
        (data) => {
          dispatch({ type: 'CHANGE_CHAT_STATUS', data });
        },
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const fetchCurrentRetailerUser = () => {
  const endpoint = `/api/v1/retailer_users/current_retailer_user`;
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
        (data) => dispatch({ type: "SET_CURRENT_RETAILER_USER", data }),
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

export const sendFacebookMultipleAnswers = (id, body, token, platform = 'messenger') => {
  const endpoint = `/api/v1/customers/${id}/messages/send_multiple_answers?platform=${platform}`;
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
