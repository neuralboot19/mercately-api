import React from 'react';

const CustomerName = ({ customer }) => {
  let customerName;
  if (customer.first_name && customer.last_name) {
    customerName = `${customer.first_name} ${customer.last_name}`;
  } else if (customer.whatsapp_name) {
    customerName = customer.whatsapp_name;
  } else {
    customerName = customer.phone;
  }

  return (
    <div className="customer_box">
      <p>
        {customerName}
        <a href={window.location.href.replace('whatsapp_chats', `customers/${customer.web_id}/edit`)} target="_blank">
          <i className="fs-18 mt-4 mr-4 f-right fas fa-external-link-alt" />
        </a>
      </p>
    </div>
  );
};

export default CustomerName;
