export const getRetailerInfo = () => {
  let endpoint = '/api/v1/retailer_info';

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
        (data) => dispatch({ type: 'GET_RETAILER_INFO', data }),
        (err) => dispatch({ type: "LOAD_DATA_FAILURE", err })
      ).catch((error) => {
      });
  };
};