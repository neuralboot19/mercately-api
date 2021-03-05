import React, { useEffect, useRef, useState } from "react";
import "react-datepicker/dist/react-datepicker.css";
import { useDispatch, useSelector } from "react-redux";
import {
  fetchCustomer as fetchCustomerAction,
  fetchCustomerFields as fetchCustomerFieldsAction,
  updateCustomer as updateCustomerAction,
  updateCustomerField as updateCustomerFieldAction
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
import IntegrationsTabContent from "./IntegrationsTabContent";

const csrfToken = document.querySelector('[name=csrf-token]').content;

const CustomerDetails = ({
  customerId,
  chatType,
  onMobile,
  backToChatMessages
}) => {
  const [state, setState] = useState({
    tags: [],
    newTag: '',
    showUserDetails: 'block',
    showCustomFields: 'none',
    showIntegrationSettings: 'none',
    fieldDate: new Date()
  });

  const [customerInfo, setCustomerInfo] = useState({});

  const [customerCustomFields, setCustomerCustomFields] = useState([]);

  const containerClassName = onMobile ? "customer_sidebar no-border-left" : "customer_sidebar";

  const dispatch = useDispatch();

  const fetchCustomerFromRedux = (id) => {
    dispatch(fetchCustomerAction(id));
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
  const customerFields = useSelector((reduxState) => reduxState.customerFields);
  const customFields = useSelector((reduxState) => reduxState.customFields);

  /**
   * Initial customer info fetch
   */
  useEffect(() => {
    fetchCustomerFromRedux(customerId);
    fetchTagsFromRedux(customerId);
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

  useEffect(() => {
    setCustomerCustomFields(customerFields);
  }, [customerFields]);

  const handleInputChange = (evt, name) => {
    setCustomerInfo({ ...customerInfo, ...{ [name]: evt.target.value } });
  };

  const handleCheckboxChange = (e) => {
    const input = e.target;
    setCustomerInfo({ ...customerInfo, ...{ 'hs_active': input.checked } });
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
      showIntegrationSettings: 'none',
      showCustomFields: 'none'
    });
  };

  const showCustomFields = () => {
    setState({
      ...state,
      showCustomFields: 'block',
      showIntegrationSettings: 'none',
      showUserDetails: 'none'
    });
  };

  const showIntegrationSettings = () => {
    setState({
      ...state,
      showUserDetails: 'none',
      showCustomFields: 'none',
      showIntegrationSettings: 'block'
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
      <CustomerName customer={customer} />
      <TabSelector
        showUserDetails={state.showUserDetails}
        showCustomFields={state.showCustomFields}
        showIntegrationSettings={state.showIntegrationSettings}
        onClickUserDetails={showUserDetails}
        onClickCustomerFields={showCustomFields}
        onClickIntegrationSettings={showIntegrationSettings}
      />
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
      <IntegrationsTabContent
        customer={customerInfo}
        onClickUserDetails={showUserDetails}
        handleCheckboxChange={handleCheckboxChange}
        showIntegrationSettings={state.showIntegrationSettings}
      />
    </div>
  );
};

export default CustomerDetails;
