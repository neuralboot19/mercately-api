import {
  SET_CUSTOMERS,
  SET_WHATSAPP_CUSTOMERS,
  SET_WHATSAPP_CUSTOMERS_REQUEST,
  LOAD_DATA_FAILURE, SET_CUSTOMERS_REQUEST,
  ERASE_DEAL, SET_ORDERS, SET_ORDERS_REQUEST,
  CHANGE_DEAL_COLUMN,
  SET_COLUMNS, SET_WHATSAPP_MESSAGES,
  SET_WHATSAPP_MESSAGES_REQUEST, SET_MESSAGES,
  SET_MESSAGES_REQUEST,
  ADD_DEALS_TO_COLUMN
} from "../actionTypes";

const initialState = {
  customers: [],
  messages: [],
  total_pages: 0,
  total_fb_pages: 0,
  total_customers: 0,
  errorSendMessageStatus: null,
  errorSendMessageText: null,
  tags: [],
  reminders: [],
  customerFields: [],
  customFields: [],
  loadingMoreCustomers: false,
  funnelSteps: [],
  orders: [],
  totalOrders: 0,
  mlChats: [],
  totalMlChats: 0,
  loadingMoreMessages: false
};

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_CURRENT_USER':
      return {
        ...state,
        currentUser: action.response.data.user
      };
    case 'SET_CUSTOMER':
      return {
        ...state,
        customer: action.data.customer,
        errors: action.data.errors,
        reminders: action.data.reminders,
        tags: action.data.tags
      };
    case 'CREATE_REMINDER':
      return {
        ...state,
        reminders: action.data.reminders
      }
    case SET_CUSTOMERS:
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        filter_tags: action.data.filter_tags,
        loadingMoreCustomers: false
      }
    case 'SET_SELECTED_CUSTOMERS':
      return {
        ...state,
        selectedCustomers: action.data.customers,
        totalSelectedCustomersPages: action.data.total_customers
      };
    case 'SET_SELECTED_CUSTOMER_IDS':
      return {
        ...state,
        contactGroupName: action.data.name,
        selectedCustomers: action.data.customers,
        selectedCustomerIds: action.data.customer_ids,
        totalSelectedCustomersPages: action.data.total_customers
      };
    case 'SET_CUSTOM_FIELDS':
      return {
        ...state,
        customerFields: action.data.customer_fields,
        customFields: action.data.custom_fields
      };
    case SET_MESSAGES:
      var balance_error = { status: null, message: null };

      if (action.data.balance_error_info)
        balance_error = action.data.balance_error_info

      return {
        ...state,
        messages: action.data.messages,
        agent_list: action.data.agent_list,
        total_pages: action.data.total_pages,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        errorSendMessageStatus: balance_error.status,
        errorSendMessageText: balance_error.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date,
        customerId: action.data.customer_id,
        filter_tags: action.data.filter_tags,
        loadingMoreMessages: false
      };
    case 'SET_SEND_MESSAGE':
      return {
        ...state,
        message: action.data.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date
      }
    case SET_WHATSAPP_CUSTOMERS:
      return {
        ...state,
        customers: action.data.customers,
        total_customers: action.data.total_customers,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        filter_tags: action.data.filter_tags,
        allowSendVoice: action.data.allow_send_voice,
        loadingMoreCustomers: false
      }
    case SET_WHATSAPP_MESSAGES:
      var balance_error = { status: null, message: null };

      if (action.data.balance_error_info)
        balance_error = action.data.balance_error_info

      return {
        ...state,
        messages: action.data.messages,
        total_pages: action.data.total_pages,
        agents: action.data.agents,
        storageId: action.data.storage_id,
        agent_list: action.data.agent_list,
        handle_message_events: action.data.handle_message_events,
        errorSendMessageStatus: balance_error.status,
        errorSendMessageText: balance_error.message,
        recentInboundMessageDate: action.data.recent_inbound_message_date,
        customerId: action.data.customer_id,
        filter_tags: action.data.filter_tags,
        allowSendVoice: action.data.allow_send_voice,
        loadingMoreMessages: false
      };
    case 'SET_LAST_MESSAGES':
      return {
        ...state,
        messages: action.data.messages,
        total_pages: action.data.totalPages,
        handle_message_events: action.data.handleMessageEvents,
        recentInboundMessageDate: action.data.recentInboundMessageDate
      };
    case 'SET_LAST_FB_MESSAGES':
      return {
        ...state,
        messages: action.data.messages,
        total_fb_pages: action.data.total_fb_pages
      };
    case 'SET_WHATSAPP_TEMPLATES':
      return {
        ...state,
        templates: action.data.templates,
        total_template_pages: action.data.total_pages
      };
    case 'CHANGE_CUSTOMER_AGENT':
      return {
        ...state,
        status: action.data.status,
        message: action.data.message
      };
    case 'UNAUTHORIZED_SEND_MESSAGE':
      return {
        ...state,
        errorSendMessageStatus: action.data.status,
        errorSendMessageText: action.data.message,
      };
    case 'SET_WHATSAPP_FAST_ANSWERS':
      return {
        ...state,
        fast_answers: action.data.templates.data,
        total_pages: action.data.total_pages
      };
    case 'SET_MESSENGER_FAST_ANSWERS':
      return {
        ...state,
        fast_answers: action.data.templates.data,
        total_pages: action.data.total_pages
      };
    case 'SET_TAGS':
      return {
        ...state,
        tags: action.data.tags
      };
    case 'SET_CREATE_CUSTOMER_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags
      };
    case 'SET_REMOVE_CUSTOMER_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags
      };
    case 'SET_CREATE_TAG':
      return {
        ...state,
        customer: action.data.customer,
        tags: action.data.tags,
        filter_tags: action.data.filter_tags
      };
    case 'SET_PRODUCTS':
      return {
        ...state,
        products: action.data.products.data,
        total_pages: action.data.total_pages
      };
    case 'SET_CHAT_BOT':
      return {
        ...state,
        customer: action.data.customer
      };
    case 'SET_CONTACT_GROUP_ERRORS':
      return {
        ...state,
        nameValidationText: action.data.errors.name?.shift(),
        customersValidationText: action.data.errors.customer_ids?.shift()
      }
    case SET_WHATSAPP_CUSTOMERS_REQUEST:
    case SET_CUSTOMERS_REQUEST:
    case SET_ORDERS_REQUEST:
      return {
        ...state,
        loadingMoreCustomers: true
      };
    case LOAD_DATA_FAILURE:
      return {
        ...state,
        loadingMoreCustomers: false,
        loadingMoreMessages: false
      };
    case 'GET_FUNNELS':
      return {
        ...state,
        funnelSteps: action.data.funnelSteps,
        fetching_funnels: true,
      }
    case 'SET_FUNNEL_DEAL':
      return {
        ...state,
      }
    case 'CLEAR_FUNNELS':
      return {
        ...state,
        fetching_funnels: false,
      }
    case 'CLEAR_NEW_DEAL':
      return {
        ...state,
        newDealSuccess: false,
      }
    case 'SET_NEW_DEAL':
      if (Object.keys(action.data).length > 0) {
        return {
          ...state,
          newDealSuccess: true,
          funnelSteps: {
            ...state.funnelSteps,
            deals: {
              ...state.funnelSteps.deals,
              [action.data.deal.id]: action.data.deal
            },
            columns: {
              ...state.funnelSteps.columns,
              [action.column]: {
                ...state.funnelSteps.columns[action.column],
                deals: state.funnelSteps.columns[action.column].deals + 1,
                dealIds: [action.data.deal.id].concat(state.funnelSteps.columns[action.column].dealIds)
              }
            }
          },
          fetching_funnels: true,
        };
      }
    case 'SET_NEW_STEP':
      if (Object.keys(action.data).length > 0) {
        let new_steps = Object.assign(state.funnelSteps.columns, {[action.data.step.id]: action.data.step});
        return {
        ...state,
          newStepSuccess: true,
          funnelSteps: {
            ...state.funnelSteps,
            columnOrder: state.funnelSteps.columnOrder.concat(action.data.step.id),
            columns: new_steps
          },
          fetching_funnels: true,
        };
      } else {
        return {
          ...state
        };
      }
    case 'CLEAR_NEW_STEP':
      return {
        ...state,
        newStepSuccess: false,
      }
    case 'ERASE_DEAL_STEP':
      if (Object.keys(action.data).length > 0) {
        let new_columns = Object.assign({}, state.funnelSteps.columns);
        delete(new_columns[action.column])
        return {
          ...state,
          funnelSteps: {
            ...state.funnelSteps,
            columnOrder: state.funnelSteps.columnOrder.filter(function(step) {
              return step !== action.column
            }),
            columns: new_columns
          },
          fetching_funnels: true,
        };
      }
    case SET_ORDERS:
      return {
        ...state,
        orders: action.data.orders,
        totalOrders: action.data.total_orders,
        loadingMoreCustomers: false
      };
    case 'SET_MLCHATS':
      return {
        ...state,
        mlChats: action.data.ml_chats,
        totalMlChats: action.data.total_ml_chats
      };
    case 'SET_MLCHAT':
      return {
        ...state,
        ml_chat: action.data.ml_chat
      };
    case ERASE_DEAL: {
      const newDeals = { ...state.funnelSteps.deals };
      delete newDeals[action.data];

      const newColumns = { ...state.funnelSteps.columns };
      newColumns[action.column].dealIds = newColumns[action.column]
        .dealIds.filter((deal) => deal !== action.data);

      newColumns[action.column].deals = newColumns[action.column].dealIds.length; 
      
      return {
        ...state,
        funnelSteps: {
          ...state.funnelSteps,
          deals: newDeals,
          columns: newColumns
        },
        fetching_funnels: true
      };
    }

    case CHANGE_DEAL_COLUMN: {
      const columnToRemoveDeal = Object.keys(state.funnelSteps.columns)
        .find((colId) => state.funnelSteps.columns[colId].dealIds
          .filter((deal) => deal === action.data.deal_id).length);

      const columnToAddDeal = state.funnelSteps.columns[action.data.funnel_step_id];

      const newColumns = { ...state.funnelSteps.columns };
      newColumns[columnToRemoveDeal].dealIds = newColumns[columnToRemoveDeal].dealIds.filter((deal) => deal !== action.data.deal_id);

      newColumns[columnToAddDeal.id].dealIds = [...newColumns[columnToAddDeal.id].dealIds, action.data.deal_id];
      newColumns[columnToRemoveDeal].deals = newColumns[columnToRemoveDeal].dealIds.length;
      newColumns[columnToAddDeal.id].deals = newColumns[columnToAddDeal.id].dealIds.length;

      return {
        ...state,
        funnelSteps: {
          ...state.funnelSteps,
          columns: newColumns
        },
        fetching_funnels: true
      };
    }

    case SET_COLUMNS: {
      return {
        ...state,
        funnelSteps: {
          ...state.funnelSteps,
          columnOrder: action.columns.columns
        },
        fetching_funnels: true
      }
    }

    case ADD_DEALS_TO_COLUMN: {
      const newColumns = state.funnelSteps.columns;
      newColumns[action.column].dealIds = [
        ...newColumns[action.column].dealIds,
        ...Object.keys(action.data.deals)
      ];

      newColumns[action.column].deals = newColumns[action.column].dealIds.length;

      return {
        ...state,
        funnelSteps: {
          ...state.funnelSteps,
          columns: newColumns,
          deals: {
            ...state.funnelSteps.deals,
            ...action.data.deals
          }
        },
        fetching_funnels: true
      };
    }

    case SET_WHATSAPP_MESSAGES_REQUEST:
    case SET_MESSAGES_REQUEST:
      return {
        ...state,
        loadingMoreMessages: true
      }

    default:
      return state;
  }
};

export default reducer;
