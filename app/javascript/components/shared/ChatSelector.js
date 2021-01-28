import React, { useEffect } from 'react';
import { useHistory, useLocation } from 'react-router-dom';

import ChatListItem from './ChatListItem';

const ChatSelector = ({
  applySearchFromAssignation,
  chatType,
  currentCustomer,
  customers,
  handleLoadMoreOnScrollToBottom,
  handleOpenChat
}) => {
  const location = useLocation();
  const history = useHistory();

  useEffect(() => {
    const queryParams = new URLSearchParams(location.search);
    if (queryParams.has('cid') && customers.length > 0) {
      const customerIdFromRoute = queryParams.get('cid');
      queryParams.delete('cid');
      history.replace({
        search: queryParams.toString()
      });
      const selectedCustomerFromRoute = customers.find((cus) => cus.id === parseInt(customerIdFromRoute, 10));
      if (selectedCustomerFromRoute) {
        handleOpenChat(selectedCustomerFromRoute);
      } else {
        applySearchFromAssignation(customerIdFromRoute);
      }
    }
  }, [customers]);

  return (
    <div className="chat__selector" onScroll={(e) => handleLoadMoreOnScrollToBottom(e)}>
      {customers.map((customer) => (
        <ChatListItem
          key={customer.id}
          currentCustomer={currentCustomer}
          customer={customer}
          handleOpenChat={handleOpenChat}
          chatType={chatType}
        />
      ))}
    </div>
  );
};

export default ChatSelector;
