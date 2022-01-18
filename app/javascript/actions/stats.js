import { forEach, orderBy } from 'lodash';

export const fetchMessagesByPlatform = (startDate, endDate) => {
  let endpoint = `/api/v1/stats/messages_by_platform?start_date=${startDate}&end_date=${endDate}`;

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
        (data) => dispatch({ type: 'SET_MESSAGES_BY_PLATFORM_DATA', data }),
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

export const fetchUsageByPlatform = (startDate, endDate) => {
  let endpoint = `/api/v1/stats/usage_by_platform?start_date=${startDate}&end_date=${endDate}`;

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
        (data) => dispatch({ type: 'SET_USAGE_BY_PLATFORM_DATA', data }),
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

export const fetchAverageResponseTimes = (startDate, endDate, agent) => {
  let endpoint = `/api/v1/stats/average_response_times?start_date=${startDate}&end_date=${endDate}&agent=${agent}`;

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
        (data) => dispatch({ type: 'SET_AVERAGE_RESPONSE_TIMES_DATA', data }),
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

export const fetchMostUsedTags = (startDate, endDate) => {
  let endpoint = `/api/v1/stats/most_used_tags?start_date=${startDate}&end_date=${endDate}`;

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
        (data) => dispatch({ type: 'SET_MOST_USED_TAGS_DATA', data }),
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

export const fetchNewAndRecurringConversations = (startDate, endDate, agent) => {
  let endpoint = `/api/v1/stats/new_and_recurring_conversations?start_date=${startDate}&end_date=${endDate}&agent=${agent}`;

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
        (data) => dispatch({ type: 'SET_NEW_AND_RECURRING_CONVERSATIONS_DATA', data }),
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

export const fetchAgentPerformance = (startDate, endDate, platform) => {
  let endpoint = `/api/v1/stats/agent_performance?start_date=${startDate}&end_date=${endDate}&platform=${platform}`;

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
        (data) => dispatch({ type: 'SET_AGENT_PERFORMANCE_DATA', data }),
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

export const fetchSentMessagesBy = (startDate, endDate, platform) => {
  let endpoint = `/api/v1/stats/sent_messages_by?start_date=${startDate}&end_date=${endDate}&platform=${platform}`;

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
        (data) => {
          forEach(data.sent_messages, message => {
            message.total_messages = Number(message.total_messages)
          })

          data.sent_messages = orderBy(data.sent_messages, ['total_messages'], ['desc']);
          dispatch({ type: 'SET_SENT_MESSAGES_DATA', data })
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