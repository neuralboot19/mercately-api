export const createGsTemplate = (body, csrfToken) => {
  const endpoint = `/api/v1/gs_templates`;

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
            let errors = data.errors;

            dispatch({ type: 'SET_GS_TEMPLATE_ERRORS', errors });
          } else {
            document.location.href = `/retailers/gupshup-retailer/gs_templates?q%5Bs%5D=created_at+desc`;
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
