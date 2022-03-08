import {
  ERASE_DEAL,
  LOAD_DATA_FAILURE,
  ADD_DEALS_TO_COLUMN
} from "../actionTypes";

/* Customers */
export const fetchFunnelSteps = (params) => {
  let endpoint = `/api/v1/funnels?`;

  if (params) {
    const queryString = new URLSearchParams(params).toString();
    endpoint += queryString;
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
        (data) => dispatch({ type: "GET_FUNNELS", data }),
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

export const updateFunnelStepDeal = (body) => {
  const endpoint = `/api/v1/funnels/update_deal`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify({ deal: body })
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'CHANGE_DEAL_COLUMN', data }),
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

export const updateFunnelStep = (body) => {
  const endpoint = `/api/v1/funnels/update_funnel_step`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify({ funnel_step: body })
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_COLUMNS', columns: body }),
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

export const createNewDeal = (body, column) => {
  const endpoint = `/api/v1/funnels/create_deal`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify({ deal: body })
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_NEW_DEAL', data, column }),
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

export const createStep = (body) => {
  const endpoint = `/api/v1/funnels/create_step`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*'
      },
      body: JSON.stringify({ funnel_step: body })
    })
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: 'SET_NEW_STEP', data }),
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

export const deleteStep = (column) => {
  const endpoint = `/api/v1/funnels/delete_step/${column}`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "DELETE",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-Access-Level": "read-write"
      }
    })
      .then((res) => res.json())
      .then((data) => {
        dispatch({ type: "ERASE_DEAL_STEP", data, column });
      })
      .catch((err) => {
        dispatch({ type: "LOAD_DATA_FAILURE", err });
      });
  };
};

export const clearFunnels = () => {
  const data = {};
  return (dispatch) => dispatch({ type: "CLEAR_FUNNELS", data });
};

export const clearNewDeal = () => {
  const data = {};
  return (dispatch) => dispatch({ type: "CLEAR_NEW_DEAL", data });
};

export const clearNewStep = () => {
  const data = {};
  return (dispatch) => dispatch({ type: "CLEAR_NEW_STEP", data });
};

export const deleteDeal = (dealId, column) => {
  const endpoint = `/api/v1/deals/${dealId}`;
  const header = {
    method: "DELETE",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json",
      "X-Access-Level": "read-write"
    }
  };
  return (dispatch) => {
    fetch(endpoint, header)
      .then((res) => res.json())
      .then((data) => {
        dispatch({ type: ERASE_DEAL, data, dealId, column });
      })
      .catch((err) => {
        dispatch({ type: LOAD_DATA_FAILURE, err });
      });
  };
};

export const loadMoreDeals = (column, page, offset = 0, params) => {
  let endpoint = `/api/v1/deals?page=${page}&column_id=${column}&offset=${offset}`;

  if (params) {
    const queryString = new URLSearchParams(params).toString();
    endpoint += `&${queryString}`;
  }

  const head = {
    method: "GET",
    credentials: "same-origin",
    headers: {
      Accept: "application/json, text/plain, */*",
      "Content-Type": "application/json"
    }
  };
  return (dispatch) => {
    fetch(endpoint, head)
      .then((res) => res.json())
      .then(
        (data) => dispatch({ type: ADD_DEALS_TO_COLUMN, data, column }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((err) => {
        dispatch({ type: LOAD_DATA_FAILURE, err });
      });
  };
};

export const fetchCustomerDeals = (customerId) => {
  const endpoint = `/api/v1/deals/customer_deals/${customerId}`;
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
        (data) => dispatch({ type: "SET_CUSTOMER_DEALS", data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch(
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      );
  };
};

export const deleteSimpleDeal = (dealId) => {
  const endpoint = `/api/v1/deals/${dealId}`;
  const header = {
    method: "DELETE",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json",
      "X-Access-Level": "read-write"
    }
  };
  return (dispatch) => {
    fetch(endpoint, header)
      .then((res) => res.json())
      .then((data) => {
        dispatch({ type: "ERASE_SIMPLE_DEAL", data});
      })
      .catch((err) => {
        dispatch({ type: LOAD_DATA_FAILURE, err });
      });
  };
};
