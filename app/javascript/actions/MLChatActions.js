import { LOAD_DATA_FAILURE, SET_ORDERS, SET_ORDERS_REQUEST } from '../actionTypes';

export const fetchOrders = (page = 1, params, offset) => {
  let endpoint = `/api/v1/orders?page=${page}&offset=${offset}`;

  if (params !== null && params !== undefined) {
    // eslint-disable-next-line no-undef
    endpoint += `&${$.param(params)}`;
  }

  return (dispatch) => {
    dispatch({ type: SET_ORDERS_REQUEST });
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
        (data) => dispatch({ type: SET_ORDERS, data }),
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

export const fetchMLChats = (id, page = 1, params) => {
  let endpoint = `/api/v1/orders/${id}/ml_chats?page=${page}`;

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
        (data) => dispatch({ type: "SET_MLCHATS", data }),
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

export const sendMLChatMessage = (id, body, csrfToken) => {
  const endpoint = `/api/v1/orders/${id}/ml_chats`;

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
        (data) => dispatch({ type: "SET_MLCHAT", data }),
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

export const markMessagesAsRead = (id) => {
  const endpoint = `/api/v1/orders/${id}/mark_messages_as_read`;

  return (dispatch) => {
    fetch(endpoint, {
      method: "PUT",
      credentials: 'same-origin'
    }).then((res) => res.json())
      .then(
        (data) => console.log({ type: "MARKED_AS_READ", data }),
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
