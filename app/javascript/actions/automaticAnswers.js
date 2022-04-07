import { handleRequestErrors } from "../services/handleRequestError";

export const getAutomaticAnswers = (page = 1) => {
  let endpoint = `/api/v1/automatic_answers?page=${page}`;

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
        (data) => dispatch({ type: 'GET_AUTOMATIC_ANSWERS', data }),
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

export const createAutomaticAnswer = (body) => {
  let endpoint = `/api/v1/automatic_answers`;

  return (dispatch) => {
    fetch(endpoint, {
      method: "POST",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      },
      body: JSON.stringify(body)
    })
    .then(handleRequestErrors)
    .then((data) => dispatch({ type: 'CREATE_AUTOMATIC_ANSWER', data })
    ).catch((error) => {
      dispatch({ type: "LOAD_DATA_FAILURE", error });
    });
  };
};

export const updateAutomaticAnswer = (id, body) => {
  let endpoint = `/api/v1/automatic_answers/${id}`;

  return (dispatch) => {
    fetch(endpoint, {
      method: "PUT",
      credentials: "same-origin",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      },
      body: JSON.stringify(body)
    })
    .then(handleRequestErrors)
    .then((data) => dispatch({ type: 'UPDATE_AUTOMATIC_ANSWER', data })
    ).catch((error) => {
      dispatch({ type: "LOAD_DATA_FAILURE", error });
    });
  };
};

export const deleteAutomaticAnswer = (id) => {
  const endpoint = `/api/v1/automatic_answers/${id}`;
  return (dispatch) => {
    fetch(endpoint, {
      method: "DELETE",
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/json"
      },
    })
    .then(handleRequestErrors)
    .then((data) => dispatch({ type: "DELETE_AUTOMATIC_ANSWER", data })
    ).catch((err) => {
      dispatch({ type: "LOAD_DATA_FAILURE", err });
    });
  };
};
