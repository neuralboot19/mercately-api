import React from 'react';

const ContactMessage = ({ contact, isReply }) => {
  return (
    <div className={`contact-card w-100 mb-10 ${isReply ? 'no-back-color' : ''}`}>
      <div className="w-100 mb-10">
        <i className="fas fa-user mr-8"></i>
        {contact.names.formatted_name}
      </div>
      {contact.phones.map((ph, index) =>
        <div key={index} className="w-100 fs-14">
          <i className="fas fa-phone-square-alt mr-8"></i>
          {ph.phone}
        </div>
      )}
      {contact.emails.map((em, index) =>
        <div key={index} className="w-100 fs-14">
          <i className="fas fa-at mr-8"></i>
          {em.email}
        </div>
      )}
      {contact.addresses.map((addrr, index) =>
        <div key={index} className="w-100 fs-14">
          <i className="fas fa-map-marker-alt mr-8"></i>
          {addrr.street ? addrr.street : (addrr.city + ', ' + addrr.state + ', ' + addrr.country)}
        </div>
      )}
      {contact.org && contact.org.company &&
      <div className="w-100 fs-14">
        <i className="fas fa-building mr-8"></i>
        {contact.org.company}
      </div>
      }
    </div>
  )
}

export default ContactMessage;