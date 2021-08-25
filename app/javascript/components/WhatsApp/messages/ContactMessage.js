import React from 'react';
import MessageStatus from '../../shared/MessageStatus';

const ContactMessage = ({ message, handleMessageEvents }) => (
  <div>
    {message.contacts_information.map((contact) => (
      <div key={message.id} className="contact-card w-100 mb-10 fs-md-and-down-12">
        <div className="w-100 mb-10">
          <i className="fas fa-user mr-8" />
          {contact.names.formatted_name}
        </div>
        {contact.phones.map((ph) => (
          <div key={ph.phone} className="w-100 fs-md-and-down-12">
            <i className="fas fa-phone-square-alt mr-8" />
            {ph.phone}
          </div>
        ))}
        {contact.emails.map((em) => (
          <div key={em.email} className="w-100 fs-md-and-down-12">
            <i className="fas fa-at mr-8" />
            {em.email}
          </div>
        ))}
        {contact.addresses.map((addrr) => (
          <div key={addrr.street} className="w-100 fs-md-and-down-12">
            <i className="fas fa-map-marker-alt mr-8" />
            {addrr.street ? addrr.street : (`${addrr.city}, ${addrr.state}, ${addrr.country}`)}
          </div>
        ))}
        {contact.org && contact.org.company && (
          <div className="w-100 fs-md-and-down-12">
            <i className="fas fa-building mr-8" />
            {contact.org.company}
          </div>
        )}
      </div>
    ))}
    <MessageStatus
      chatType="whatsapp"
      handleMessageEvents={handleMessageEvents}
      message={message}
    />
  </div>
);

export default ContactMessage;
