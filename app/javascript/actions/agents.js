export const fetchAgents = () => {
  let endpoint = `/api/v1/retailer_users`;

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
        (data) => dispatch({ type: 'SET_AGENTS_DATA', data }),
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