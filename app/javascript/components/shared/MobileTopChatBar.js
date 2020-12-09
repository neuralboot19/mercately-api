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
    containerClass = 'col-xs-12 row';
    unreadMessagePropertyName = 'unread_whatsapp_message?';
  } else {
    containerClass = 'col-xs-12 row mb-15';
    unreadMessagePropertyName = 'unread_message?';
  }

  return (
    <div className={containerClass}>
      <div className="col-xs-2 pl-0" onClick={() => backToChatList()}>
        <i className="fas fa-arrow-left c-secondary fs-30 mt-12">
        </i>
      </div>
      <div className="col-xs-8 pl-0">
        <div className="profile__name">
          {customerName}
        </div>
        <div className={customerDetails[unreadMessagePropertyName] ? 'fw-bold' : ''}>
          <small>{moment(customerDetails.recent_message_date).locale('es').fromNow()}</small>
        </div>
      </div>
      <div className="col-xs-2 pl-0" onClick={() => editCustomerDetails()}>
        <div className="c-secondary mt-12">
          Editar
        </div>
      </div>
    </div>
  )
}

export default MobileTopChatBar;
