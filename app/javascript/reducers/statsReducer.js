const initialState = {
  messagesByPlatform: {
    ws: {total_inbound: 0, total_outbound: 0, total_messages: 0},
    msn: {total_inbound: 0, total_outbound: 0, total_messages: 0},
    ig: {total_inbound: 0, total_outbound: 0, total_messages: 0},
    ml: {total_inbound: 0, total_outbound: 0, total_messages: 0},
  },
  usageByPlatform: {
    percentage_total_ws_messages: 0,
    percentage_total_msn_messages: 0,
    percentage_total_ig_messages: 0,
    percentage_total_ml_messages: 0
  },
  averageResponseTimes: [],
  mostUsedTags: [],
  newAndRecurringConversationsData: [],
  agentPerformance: [],
  setMessagesBy: []
};

const statsReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_MESSAGES_BY_PLATFORM_DATA': {
      return {
        ...state,
        messagesByPlatform: action.data.messages_by_platform
      }
    }
    case 'SET_USAGE_BY_PLATFORM_DATA': {
      return {
        ...state,
        usageByPlatform: action.data.usage_by_platform
      }
    }
    case 'SET_AVERAGE_RESPONSE_TIMES_DATA': {
      return {
        ...state,
        averageResponseTimes: action.data.average_response_times
      };
    }
    case 'SET_MOST_USED_TAGS_DATA': {
      return {
        ...state,
        mostUsedTags: action.data.most_used_tags
      };
    }
    case 'SET_NEW_AND_RECURRING_CONVERSATIONS_DATA': {
      return {
        ...state,
        newAndRecurringConversationsData: action.data.conversations_data
      };
    }
    case 'SET_AGENT_PERFORMANCE_DATA': {
      return {
        ...state,
        agentPerformance: action.data.agent_performance
      };
    }
    case 'SET_SENT_MESSAGES_DATA': {
      return {
        ...state,
        setMessagesBy: action.data.sent_messages
      };
    }
    default:
      return state;
  }
};

export default statsReducer;
