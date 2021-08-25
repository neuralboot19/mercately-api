import React from 'react';

const MobileTopChatBar = ({ backToChatList, chatType, customerDetails, editCustomerDetails }) => {

  const getCustomerName = () => {
    if (customerDetails.first_name && customerDetails.last_name) {
      return `${customerDetails.first_name} ${customerDetails.last_name}`;
    }
    if (chatType === 'whatsapp' && customerDetails.whatsapp_name) {
      return customerDetails.whatsapp_name;
    }
    return customerDetails.phone;
  };

  let containerClass;
  let unreadMessagePropertyName;
  const customerName = getCustomerName();

  if (chatType === 'whatsapp') {
    containerClass = 'col-12 row mx-0 mt-8 pt-12';
    unreadMessagePropertyName = 'unread_whatsapp_message?';
  } else {
    containerClass = 'col-12 row mx-0 pt-12';
    unreadMessagePropertyName = 'unread_message?';
  }

  return (
    <div className={containerClass}>
      <div className="col-2 pl-0 flex-center-xy" onClick={() => backToChatList()}>
        <i className="fas fa-arrow-left c-secondary fs-30">
        </i>
      </div>
      <div className="col-8 pl-0">
        <div className="profile__name fs-sm-and-down-12 text-truncate">
          {customerName}
        </div>
        <div className={customerDetails[unreadMessagePropertyName] ? 'fw-bold' : ''}>
          <small>{moment(customerDetails.recent_message_date).locale('es').fromNow()}</small>
        </div>
      </div>
      <div className="col-2 pl-0" onClick={() => editCustomerDetails()}>
        <div className="c-secondary mt-12">
          Editar
        </div>
      </div>
    </div>
  )
}

export default MobileTopChatBar;
