import React from 'react';
import OrderSelector from './OrderSelector';
import { useSelector } from 'react-redux';
import LoadMore from '../shared/LoadMore';

const OrderList = ({
  orders,
  handleLoadMoreOnScrollToBottom,
  selectOrder,
  selectedChat
}) => {
  const loadingMoreCustomers = useSelector((reduxState) => reduxState.loadingMoreCustomers);

  return (
    <div id="ml-chat__selector" className="chat__selector" style={{ height: '82vh' }} onScroll={(e) => handleLoadMoreOnScrollToBottom(e)}>
      {orders.map((order) => (
        <OrderSelector
          key={order.id}
          order={order}
          selectOrder={selectOrder}
          selectedChat={selectedChat}
        />
      ))}
      {loadingMoreCustomers && <LoadMore />}
    </div>
  );
};

export default OrderList;
