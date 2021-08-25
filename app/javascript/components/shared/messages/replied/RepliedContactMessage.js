import React from 'react';

/**
 * Replied message, by now, replied messages are inbound only.
 * @param contact
 * @param isReply
 * @returns {JSX.Element}
 * @constructor
 */
const RepliedContactMessage = ({ contact }) => (
  <div className="contact-card w-100 mb-10 no-back-color fs-md-and-down-12">
    <div className="w-100 mb-10">
      <i className="fas fa-user mr-8" />
      {contact.names.formatted_name}
    </div>
    {contact.phones.map((ph) => (
      <div key={ph.id} className="w-100 fs-md-and-down-12">
        <i className="fas fa-phone-square-alt mr-8" />
        {ph.phone}
      </div>
    ))}
    {contact.emails.map((em) => (
      <div key={em.id} className="w-100 fs-md-and-down-12">
        <i className="fas fa-at mr-8" />
        {em.email}
      </div>
    ))}
    {contact.addresses.map((addrr) => (
      <div key={addrr.id} className="w-100 fs-md-and-down-12">
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
);

export default RepliedContactMessage;
