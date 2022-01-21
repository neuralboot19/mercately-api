/* Customers */

import {
  LOAD_DATA_FAILURE,
  SET_WHATSAPP_CUSTOMERS,
  SET_WHATSAPP_CUSTOMERS_REQUEST,
  SET_WHATSAPP_MESSAGES,
  SET_WHATSAPP_MESSAGES_REQUEST,
  SET_BLOCK_USER
} from "../actionTypes";

export const fetchWhatsAppCustomers = (page = 1, params, offset) => {
  let endpoint = `/api/v1/karix_whatsapp_customers?page=${page}&offset=${offset}`;

  if (params !== null && params !== undefined) {
    // eslint-disable-next-line no-undef
    endpoint += `&${$.param(params)}`;
  }

  return (dispatch) => {
    dispatch({ type: SET_WHATSAPP_CUSTOMERS_REQUEST });
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
        (data) => {
          dispatch({
            type: SET_WHATSAPP_CUSTOMERS,
            data
          });
        },
        (err) => {
          dispatch({
            type: LOAD_DATA_FAILURE,
            err
          });
        }
      ).catch((error) => {
        if (error.response) {
          alert(error.response);
        } else {
          alert("An unexpected error occurred.");
        }
      });
  };
};

export const sendWhatsAppMessage = (body, token) => {
  const endpoint = `/api/v1/karix_send_whatsapp_message`;
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
        (data) => {
          if (data.status && data.status === 401) {
            dispatch({ type: 'UNAUTHORIZED_SEND_MESSAGE', data });
          } else {
            dispatch({ type: 'SET_SEND_MESSAGE', data });
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

export const fetchWhatsAppMessages = (id, page = 1) => {
  const endpoint = `/api/v1/karix_whatsapp_customers/${id}/messages?page=${page}`;
  return (dispatch) => {
    dispatch({ type: SET_WHATSAPP_MESSAGES_REQUEST });
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
        (data) => dispatch({ type: SET_WHATSAPP_MESSAGES, data }),
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

export const setLastMessages = (customerDetails) => (
  (dispatch) => dispatch({
    type: "SET_LAST_MESSAGES",
    data: {
      messages: customerDetails.last_messages.messages,
      totalPages: customerDetails.last_messages.total_pages,
      handleMessageEvents: customerDetails['handle_message_events?'],
      recentInboundMessageDate: customerDetails.recent_inbound_message_date
    }
  })
);

export const setLastFBMessages = (customerDetails) => (
  (dispatch) => {
    return dispatch({
      type: "SET_LAST_FB_MESSAGES",
      data: {
        messages: customerDetails.last_fb_messages.messages,
        total_fb_pages: customerDetails.last_fb_messages.total_pages
      }
    })
  }
);

export const sendWhatsAppImg = (id, body, token) => {
  const endpoint = `/api/v1/karix_whatsapp_send_file/${id}`;
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

export const setWhatsAppMessageAsRead = (id, body, token) => {
  const endpoint = `/api/v1/whatsapp_update_message_read/${id}`;
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

export const fetchWhatsAppTemplates = () => {
  const endpoint = `/api/v1/whatsapp_templates`;
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
        (data) => dispatch({ type: "SET_WHATSAPP_TEMPLATES", data }),
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

export const changeCustomerAgent = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/assign_agent`;
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
        (data) => dispatch({ type: 'CHANGE_CUSTOMER_AGENT', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const getWhatsAppFastAnswers = (page = 1, params) => {
  let endpoint = `/api/v1/fast_answers_for_whatsapp?page=${page}`;

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
        (data) => dispatch({ type: "SET_WHATSAPP_FAST_ANSWERS", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const setNoRead = (customerId, token, chatService = 'whatsapp') => {
  const endpoint = `/api/v1/whatsapp_unread_chat/${customerId}`;
  const csrfToken = token;
  // eslint-disable-next-line no-unused-vars
  return (dispatch) => {
    fetch(endpoint, {
      method: "PATCH",
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify({ chat_service: chatService })
    }).catch((error) => {
      if (error.response) alert(error.response);
      else alert("An unexpected error occurred.");
    });
  };
};

export const fetchTags = (id) => {
  const endpoint = `/api/v1/customers/${id}/selectable_tags`;

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

export const createCustomerTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/add_customer_tag`;
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
        (data) => dispatch({ type: 'SET_CREATE_CUSTOMER_TAG', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const removeCustomerTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/remove_customer_tag`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: "DELETE",
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
        (data) => dispatch({ type: 'SET_REMOVE_CUSTOMER_TAG', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const createTag = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/add_tag`;
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
        (data) => dispatch({ type: 'SET_CREATE_TAG', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const toggleChatBot = (id, body, token) => {
  const endpoint = `/api/v1/customers/${id}/toggle_chat_bot`;
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
        (data) => dispatch({ type: 'SET_CHAT_BOT', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const sendWhatsAppBulkFiles = (id, body, token) => {
  const endpoint = `/api/v1/karix_whatsapp_send_bulk_files/${id}`;
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

export const createReminder = (body, token) => {
  const endpoint = `/api/v1/reminders`;
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
        (data) => dispatch({ type: 'CREATE_REMINDER', data }),
        (err) => dispatch({ type: 'LOAD_DATA_FAILURE', err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert("An unexpected error occurred.");
      });
  };
};

export const sendWhatsAppMultipleAnswers = (id, body, token) => {
  const endpoint = `/api/v1/send_multiple_whatsapp_answers/${id}`;
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

export const toggleBlockUser = (id, token) => {
  const endpoint = `/api/v1/customers/${id}/toggle_block_user`;
  const csrfToken = token;
  return (dispatch) => {
    fetch(endpoint, {
      method: 'PUT',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      }
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: SET_BLOCK_USER, data }),
        (err) => dispatch({ type: LOAD_DATA_FAILURE, err })
      ).catch((error) => {
        if (error.response) alert(error.response);
        else alert('An unexpected error occurred.');
      });
  };
};
