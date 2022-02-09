import React from 'react';
import OrderSelector from './OrderSelector';
import { useSelector } from 'react-redux';
import LoadMore from '../shared/LoadMore';

const OrderList = ({
  orders,
  handleLoadMoreOnScrollToBottom,
  selectOrder,
  selectedChat,
  loading
}) => {
  const loadingMoreCustomers = useSelector((reduxState) => reduxState.mainReducer.loadingMoreCustomers);

  return (

    <div id="ml-chat__selector" className="col-xs-12 col-md-3 no-border-right no-padding-xs" style={{ height: '82vh' }} onScroll={(e) => handleLoadMoreOnScrollToBottom(e)}>
      {loading
        ? <LoadMore />
        : (
        <div className="chat_list_holder overflow-auto">
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
      )}
    </div>
  );
};

export default OrderList;
