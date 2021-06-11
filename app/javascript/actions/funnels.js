/* Customers */
export const fetchFunnelSteps = () => {
  const endpoint = `/api/v1/funnels`;

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
        (data) => dispatch({ type: 'SET_FUNNEL_DEAL', data }),
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
        (data) => dispatch({ type: 'SET_FUNNEL_DEAL', data }),
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

export const deleteDeal = (data, column) => {
  const endpoint = `/api/v1/deals/${data}`;
  const header = {
    method: "DELETE",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json",
      "X-Access-Level": "read-write"
    }

  };
  return async (dispatch) => {
    try {
      const deleteDealResponse = await fetch(endpoint, header);
      if (!deleteDealResponse.ok) throw Error(deleteDealResponse.statusText);
      dispatch({ type: "ERASE_DEAL", data, column });
    } catch (error) {
      alert(error);
    }
  };
};
