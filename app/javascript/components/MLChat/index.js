import React, { useEffect, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import Lightbox from 'react-image-lightbox';

import {
  fetchOrders,
  fetchMLChats,
  sendMLChatMessage,
  markMessagesAsRead
} from '../../actions/MLChatActions';
import OrderList from './OrderList';
import ChatWindow from './ChatWindow';
import SelectChatLabel from '../shared/SelectChatLabel';
import LoadMore from '../shared/LoadMore';

const csrfToken = document.querySelector('[name=csrf-token]').content;

const MLChat = () => {
  const [state, setState] = useState({
    selectedChat: null,
    selectedOrder: {},
    currentPage: 1,
    currentChatPage: 1,
    orders: [],
    orderMessages: [],
    imageUrl: '',
    isOpenImage: false
  });

  const [loading, setLoading] = useState(true);
  const isMounted = useRef(false);

  const dispatch = useDispatch();
  const orders = useSelector((reduxState) => reduxState.mainReducer.orders);
  const totalOrderPages = useSelector((reduxState) => reduxState.mainReducer.totalOrders);
  const orderMessages = useSelector((reduxState) => reduxState.mainReducer.mlChats);
  const totalOrderMessages = useSelector((reduxState) => reduxState.mainReducer.totalMlChats);
  const loadingMoreCustomers = useSelector((reduxState) => reduxState.mainReducer.loadingMoreCustomers);

  const bottomRef = useRef(null);

  useEffect(() => {
    socket.on('ml_messages', (data) => updateChat(data));
    socket.on('ml_orders', (data) => {
      if (data.order_web_id) {
        markOrderAsRead(data.order_web_id);
      } else {
        updateOrders(data);
      }
    });

    return () => {
      socket.off('ml_messages');
      socket.off('ml_orders');
    };
  });

  useEffect(() => {
    dispatch(fetchOrders(state.currentPage, null, state.orders.length));
  }, [dispatch, state.currentPage]);

  useEffect(() => {
    if (isMounted.current) {
      setLoading(false);
      setState((prevState) => ({
        ...prevState,
        orders: state.orders.concat(orders)
      }));
    } else {
      isMounted.current = true;
    }
  }, [orders]);

  useEffect(() => {
    if (state.selectedOrder.id !== orderMessages[0]?.order_id) return;

    setState((prevState) => ({
      ...prevState,
      orderMessages: orderMessages.concat(state.orderMessages)
    }));
  }, [orderMessages]);

  useEffect(() => {
    if (state.currentChatPage === 1 && bottomRef.current) scrollToBottom();
  }, [state.orderMessages]);

  useEffect(() => {
    const { selectedChat, currentChatPage } = state;
    if (selectedChat === null) return;

    dispatch(fetchMLChats(selectedChat, currentChatPage));
  }, [dispatch, state.selectedChat, state.currentChatPage]);

  const scrollToBottom = () => {
    bottomRef.current.scrollIntoView();
  };

  const updateChat = (data) => {
    const { message } = data;
    if (!state.orderMessages[0]) return;
    if (message.order_id !== state.orderMessages[0].order_id) return;

    const orderId = message.order_id;
    const order = state.orders.find((orderEl) => (orderEl.id === orderId));
    const orderIndex = state.orders.findIndex((orderEl) => (orderEl.id === orderId));
    const newOrders = state.orders;

    if (order.unread_message) {
      order.unread_message = false;
      newOrders[orderIndex] = order;
    }
    dispatch(markMessagesAsRead(order.web_id));
    setState({
      ...state,
      orders: newOrders,
      orderMessages: [
        ...state.orderMessages,
        message
      ]
    });
  };

  const markOrderAsRead = (orderWebId) => {
    const newOrders = [...state.orders];
    const orderIndex = newOrders.findIndex((orderEl) => (orderEl.web_id === orderWebId));
    if (orderIndex >= 0) {
      newOrders[orderIndex].unread_message = false;
      setState({
        ...state,
        orders: newOrders
      });
    }
  };

  const updateOrders = (data) => {
    const { order } = data;
    const orderInOrders = state.orders.find((orderEl) => (orderEl.id === order.id));
    let newOrders = [...state.orders];

    if (orderInOrders) _.remove(newOrders, (el) => (el.id === order.id));
    newOrders.unshift(order);

    if (state.selectedChat === order.web_id) {
      state.orders = newOrders;
    } else {
      setState({
        ...state,
        orders: newOrders
      });
    }
  };

  const handleLoadMoreOnScrollToBottom = (e) => {
    if (state.currentPage > totalOrderPages || loadingMoreCustomers) return;

    const el = e.target;
    const style = window.getComputedStyle(el, null);
    const scrollHeight = parseInt(style.getPropertyValue('height'), 10);

    if (el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      setState((prevState) => (
        {
          ...state,
          currentPage: prevState.currentPage + 1
        }
      ));
    }
  };

  const handleSubmitMessage = (e, message) => {
    const order = state.selectedOrder;
    let newOrders = [...state.orders];
    if (order.last_message) {
      order.last_message.created_at = Date.now();
    } else {
      order.created_at = Date.now();
    }
    dispatch(sendMLChatMessage(state.selectedChat, { answer: message }, csrfToken));
    order.unread_message = false;
    _.remove(newOrders, (el) => (el.id === order.id));
    setState({
      ...state,
      orders: [
        order,
        ...newOrders
      ],
      orderMessages: [
        ...state.orderMessages,
        {
          answer: message,
          attachments: [],
          order_id: state.selectedChat,
          created_at: Date.now()
        }
      ]
    });
  };

  const selectOrder = (id) => {
    if (state.selectedChat === id) return;

    const order = state.orders.find((orderEl) => (orderEl.web_id === id));
    const orderIndex = state.orders.findIndex((orderEl) => (orderEl.web_id === id));
    const newOrders = state.orders;

    if (order.unread_message) {
      order.unread_message = false;
      newOrders[orderIndex] = order;
    }

    setState({
      ...state,
      selectedChat: id,
      selectedOrder: order,
      orders: newOrders,
      orderMessages: [],
      currentChatPage: 1
    });
  };

  const handleScrollToTop = (e) => {
    if (state.currentChatPage >= totalOrderMessages) return;

    const el = e.target;
    if (el.scrollTop >= 0 && el.scrollTop <= 5) {
      el.scrollTop = 10;
      const { currentChatPage } = state;
      const nextChatPage = currentChatPage + 1;
      setState({
        ...state,
        currentChatPage: nextChatPage
      });
    }
  };

  const openImage = (url) => {
    setState({
      ...state,
      imageUrl: url,
      isOpenImage: true
    });
  };

  return (
    <div>
      <div className="container-fluid">
        <div className="row no-left-margin-xs">
          <OrderList
            orders={state.orders}
            handleLoadMoreOnScrollToBottom={handleLoadMoreOnScrollToBottom}
            selectOrder={selectOrder}
            selectedChat={state.selectedChat}
            loading={loading}
          />

          {state.selectedChat === null && (
            <SelectChatLabel />
          )}
          {state.selectedChat && (
            <div className="col-xs-12 col-md-9 no-padding-xs">
              <div className="">
                <div className="chat-messages-holder p-24">
                  <ChatWindow
                    state={state}
                    handleScrollToTop={handleScrollToTop}
                    bottomRef={bottomRef}
                    openImage={openImage}
                    handleSubmitMessage={handleSubmitMessage}
                  />
                </div>
              </div>
            </div>
          )}

        </div>

        {state.isOpenImage && (
          <Lightbox
            mainSrc={state.imageUrl}
            onCloseRequest={() => setState({ ...state, isOpenImage: false })}
            imageLoadErrorMessage="Error al cargar la imagen"
          />
        )}
      </div>
    </div>
  );
};

export default MLChat;
