export const createGsTemplate = (body, csrfToken) => {
  const endPoint = `/api/v1/gs_templates`;

  return (dispatch) => {
    fetch(endPoint, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body: body
    })
      .then((res) => res.json())
      .then(
        (data) => {
          if (data.errors) {
            let errors = data.errors;
            dispatch({ type: 'SET_GS_TEMPLATE_ERRORS', errors });
            dispatch({ type: 'TOGGLE_SUBMITTED', submitted: false });
          } else {
            document.location.href = `/retailers/gupshup-retailer/gs_templates?q%5Bs%5D=created_at+desc`;
          }
        },
        (err) => {
          dispatch({ type: 'LOAD_DATA_FAILURE', err });
          dispatch({ type: 'TOGGLE_SUBMITTED', submitted: false });
        }
      ).catch((error) => {
        if (error.response) {
          dispatch({ type: 'TOGGLE_SUBMITTED', submitted: false });
          alert(error.response);
        } else {
          dispatch({ type: 'TOGGLE_SUBMITTED', submitted: false });
          alert("An unexpected error occurred.");
        }
      });
  };
};
