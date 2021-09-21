import React, { useEffect, useRef, useState } from "react";
import "react-datepicker/dist/react-datepicker.css";
import { useDispatch, useSelector } from "react-redux";
import {
  cancelReminder as cancelReminderAction,
  fetchCustomer as fetchCustomerAction,
  fetchCustomerFields as fetchCustomerFieldsAction,
  updateCustomer as updateCustomerAction,
  updateCustomerField as updateCustomerFieldAction,
  fetchNotes as fetchNotesAction
} from "../../../actions/actions";
import {
  fetchTags as fetchTagsAction,
  createCustomerTag as createCustomerTagAction,
  removeCustomerTag as removeCustomerTagAction,
  createTag as createTagAction
} from "../../../actions/whatsapp_karix";
import MobileHeader from "./MobileHeader";
import CustomerName from "./CustomerName";
import TabSelector from "./TabSelector";
import CustomerDetailsTabContent from "./CustomerDetailsTabContent";
import CustomFieldsTabContent from "./CustomFieldsTabContent";
import AutomationsTabContent from "./AutomationsTabContent";
import IntegrationsTabContent from "./IntegrationsTabContent";
import NotesTabContent from "./NotesTabContent";

const csrfToken = document.querySelector('[name=csrf-token]').content;

const CustomerDetails = ({
  customerId,
  chatType,
  onMobile,
  backToChatMessages
}) => {
  const [state, setState] = useState({
    tags: [],
    reminders: [],
    newTag: '',
    showUserDetails: 'block',
    showCustomFields: 'none',
    showAutomationSettings: 'none',
    showIntegrationSettings: 'none',
    showNotes: 'none',
    fieldDate: new Date()
  });

  const [customerInfo, setCustomerInfo] = useState({});

  const [customerCustomFields, setCustomerCustomFields] = useState([]);

  const [customerNotes, setCustomerNotes] = useState([]);

  const containerClassName = onMobile ? "customer_sidebar no-border-left" : "customer_sidebar";

  const dispatch = useDispatch();

  const fetchCustomerFromRedux = (id) => {
    dispatch(fetchCustomerAction(id));
  };

  const fetchNotesFromRedux = (id) => {
    dispatch(fetchNotesAction(id, chatType));
  };

  const cancelReminderFromRedux = (reminderId) => {
    dispatch(cancelReminderAction(reminderId));
  };

  const updateCustomerFromRedux = (id, body, token) => {
    dispatch(updateCustomerAction(id, body, token));
  };

  const updateCustomerFieldRedux = (customFieldId, body) => {
    dispatch(updateCustomerFieldAction(customerId, customFieldId, body, csrfToken));
  };

  const fetchTagsFromRedux = (id) => {
    dispatch(fetchTagsAction(id));
  };

  const createCustomerTagFromRedux = (id, params, token) => {
    dispatch(createCustomerTagAction(id, params, token));
  };

  const removeCustomerTagRedux = (id, params, token) => {
    dispatch(removeCustomerTagAction(id, params, token));
  };

  const createTagRedux = (id, params, token) => {
    dispatch(createTagAction(id, params, token));
  };

  const fetchCustomerFieldsFromRedux = () => {
    dispatch(fetchCustomerFieldsAction(customerId));
  };

  const customer = useSelector((reduxState) => reduxState.customer) || {};
  const tags = useSelector((reduxState) => reduxState.tags) || [];
  const reminders = useSelector((reduxState) => reduxState.reminders) || [];
  const customerFields = useSelector((reduxState) => reduxState.customerFields);
  const customFields = useSelector((reduxState) => reduxState.customFields);
  const customerReduxNotes = useSelector((reduxState) => reduxState.customerNotes);

  /**
   * Initial customer info fetch
   */
  useEffect(() => {
    !onMobile && fetchCustomerFromRedux(customerId);
    fetchTagsFromRedux(customerId);
    fetchNotesFromRedux(customerId);
    fetchCustomerFieldsFromRedux(customerId);
  }, [customerId]);

  useEffect(() => {
    const {
      first_name: firstName,
      last_name: lastName,
      email,
      id_type: idType,
      id_number: idNumber,
      address,
      city,
      state: addressState,
      notes,
      hs_active,
      hs_id,
      phone,
      emoji_flag: emojiFlag
    } = customer;
    setCustomerInfo({
      first_name: firstName,
      last_name: lastName,
      email,
      id_type: idType,
      id_number: idNumber,
      address,
      city,
      state: addressState,
      notes,
      hs_active,
      hs_id,
      phone,
      emoji_flag: emojiFlag
    });
  }, [customer.id,
    customer.first_name,
    customer.last_name,
    customer.email,
    customer.id_type,
    customer.id_number,
    customer.address,
    customer.city,
    customer.state,
    customer.notes,
    customer.hs_active,
    customer.hs_id,
    customer.phone,
    customer.emoji_flag]);

  useEffect(() => {
    setState({ ...state, customerFields });
  }, [customerFields]);

  const isMounted = useRef(false);

  useEffect(() => {
    if (isMounted.current
      && customerInfo.id_type
      && customerInfo.id_type !== customer.id_type
    ) {
      handleSubmit();
    } else {
      isMounted.current = true;
    }
  }, [customerInfo.id_type]);

  const isMountedAux = useRef(false);
  useEffect(() => {
    if (isMountedAux.current
      && customerInfo.hs_active !== undefined
      && customerInfo.hs_active !== customer.hs_active
    ) {
      handleSubmit();
    } else {
      isMountedAux.current = true;
    }
  }, [customerInfo.hs_active]);

  useEffect(() => {
    setCustomerCustomFields(customerFields);
  }, [customerFields]);

  useEffect(() => {
    setCustomerNotes(customerReduxNotes);
  }, [customerReduxNotes]);

  const handleInputChange = (evt, name) => {
    setCustomerInfo({ ...customerInfo, ...{ [name]: evt.target.value } });
  };

  const handleCheckboxChange = (e) => {
    const input = e.target;
    setCustomerInfo({ ...customerInfo, ...{ [input.name]: input.checked } });
  };

  const handleEnter = (e) => {
    if (e.keyCode === 13 && !e.shiftKey) {
      e.preventDefault();
      e.target.blur();
    }
  };

  const handleSubmit = () => {
    updateCustomerFromRedux(customer.id, { customer: customerInfo }, csrfToken);
  };

  const cancelReminder = (reminderId) => {
    if (window.confirm('¿Estás seguro de cancelar este recordatorio?')) {
      cancelReminderFromRedux(reminderId);
    }
  };

  const handleIdTypeChange = (option) => {
    setCustomerInfo({ ...customerInfo, ...{ id_type: option.value } });
  };

  const handleSelectTagChange = (option) => {
    const params = {
      tag_id: option.value,
      chat_service: chatType === 'facebook_chats' ? 'facebook' : 'whatsapp'
    };

    createCustomerTagFromRedux(customer.id, params, csrfToken);
  };

  const removeCustomerTag = (tag) => {
    const params = {
      tag_id: tag.id,
      chat_service: chatType === 'facebook_chats' ? 'facebook' : 'whatsapp'
    };

    removeCustomerTagRedux(customer.id, params, csrfToken);
  };

  const onKeyPress = (e) => {
    if (e.which === 13) {
      e.preventDefault();
      if (state.newTag.trim() === '') {
        return;
      }
      createTag();
    }
  };

  const handleNewTagChange = (e) => {
    setState({
      ...state,
      [e.target.name]: e.target.value
    });
  };

  const createTag = () => {
    const params = {
      tag: state.newTag,
      chat_service: chatType === 'facebook_chats' ? 'facebook' : 'whatsapp'
    };

    createTagRedux(customer.id, params, csrfToken);
    setState({ ...state, newTag: '' });
  };

  const showUserDetails = () => {
    setState({
      ...state,
      showUserDetails: 'block',
      showAutomationSettings: 'none',
      showIntegrationSettings: 'none',
      showCustomFields: 'none',
      showNotes: 'none'
    });
  };

  const showCustomFields = () => {
    setState({
      ...state,
      showCustomFields: 'block',
      showAutomationSettings: 'none',
      showIntegrationSettings: 'none',
      showUserDetails: 'none',
      showNotes: 'none'
    });
  };

  const showAutomationSettings = () => {
    setState({
      ...state,
      showUserDetails: 'none',
      showCustomFields: 'none',
      showAutomationSettings: 'block',
      showIntegrationSettings: 'none',
      showNotes: 'none'
    });
  };

  const showIntegrationSettings = () => {
    setState({
      ...state,
      showUserDetails: 'none',
      showCustomFields: 'none',
      showAutomationSettings: 'none',
      showIntegrationSettings: 'block',
      showNotes: 'none'
    });
  };

  const showNotes = () => {
    setState({
      ...state,
      showUserDetails: 'none',
      showCustomFields: 'none',
      showAutomationSettings: 'none',
      showIntegrationSettings: 'none',
      showNotes: 'block'
    });
  };

  const updateCustomerField = (customerField, customField) => {
    updateCustomerFieldRedux(customField.id, { [customField.identifier]: customerField });
  };

  return (
    <div className={containerClassName}>
      {onMobile && (
        <MobileHeader onBack={backToChatMessages} />
      )}
      <CustomerName customer={customer} chatType={chatType} />
      <TabSelector
        showUserDetails={state.showUserDetails}
        showCustomFields={state.showCustomFields}
        showAutomationSettings={state.showAutomationSettings}
        showIntegrationSettings={state.showIntegrationSettings}
        showNotes={state.showNotes}
        onClickUserDetails={showUserDetails}
        onClickCustomerFields={showCustomFields}
        onClickAutomationSettings={showAutomationSettings}
        onClickIntegrationSettings={showIntegrationSettings}
        onClickNotes={showNotes}
      />
      <div className="customer-tab-selected">
        <CustomerDetailsTabContent
          chatType={chatType}
          showUserDetails={state.showUserDetails}
          customer={customerInfo}
          customerId={customer.id}
          customerTags={customer.tags}
          handleEnter={handleEnter}
          handleInputChange={handleInputChange}
          handleSubmit={handleSubmit}
          handleSelectChange={handleIdTypeChange}
          handleSelectTagChange={handleSelectTagChange}
          tags={tags}
          newTag={state.newTag}
          handleNewTagChange={handleNewTagChange}
          onKeyPress={onKeyPress}
          removeCustomerTag={removeCustomerTag}
        />
        <CustomFieldsTabContent
          customFields={customFields}
          customerFields={customerCustomFields}
          showCustomFields={state.showCustomFields}
          updateCustomerField={updateCustomerField}
        />
        <AutomationsTabContent
          reminders={reminders}
          cancelReminder={cancelReminder}
          showAutomationSettings={state.showAutomationSettings}
        />
        <IntegrationsTabContent
          customer={customerInfo}
          onClickUserDetails={showUserDetails}
          handleCheckboxChange={handleCheckboxChange}
          showIntegrationSettings={state.showIntegrationSettings}
        />
        <NotesTabContent
          notes={customerNotes}
          showNotes={state.showNotes}
        />
      </div>
    </div>
  );
};

export default CustomerDetails;
