/* Customers */
export const fetchCustomers = () => {
  const endpoint = '/api/v1/customers';
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
