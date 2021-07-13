import React from 'react';
import moment from 'moment';

const OrderSelector = ({ order, selectOrder, selectedChat }) => {
  let containerClassName = 'profile fs-14';
  if (order.web_id === selectedChat) {
    containerClassName = 'fs-14 chat-selected';
  }

  const orderStatus = (status) => {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'success':
        return 'Completado';
      default:
        return 'Cancelado';
    }
  };

  let lastMessage;
  if (order.last_message) {
    lastMessage = order.last_message.created_at;
  } else {
    lastMessage = order.created_at;
  }

  return (
    <div>
      <div className={containerClassName} onClick={() => selectOrder(order.web_id)}>
        <div className="profile__data row mx-0">
          {order.unread_message && order.web_id !== selectedChat && (
            <div className="tooltip">
              <b className="item__cookie item__cookie_whatsapp_messages notification">
                {order.unread_messages_count}
              </b>
            </div>
          )}
          <div className="img__profile col-2 p-0">
            <div className="rounded-circle mw-100">
              <img src={order.order_img} className="rounded-circle" />
            </div>
          </div>
          <div className="col-10 profile__info">
            <div className="profile__name">
              {order.customer.first_name} {order.customer.last_name}
              <div className="fw-muted time-from float-right">
                {moment(lastMessage).locale('es').fromNow()}
              </div>
            </div>
            <div className="assigned-customer">
              <small>{order.products[0].title}</small>
            </div>
          </div>
          <div className="row mt-15 w-100 show-to-right">
            <div className="customer-tags-chats">
              {orderStatus(order.status)}
            </div>
          </div>
        </div>
      </div>
      <hr className="chat_separator" />
    </div>
  );
};

export default OrderSelector;
