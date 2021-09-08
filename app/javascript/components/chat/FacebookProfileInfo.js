import React from 'react';
import DoubleCheckIcon from '../icons/DoubleCheckIcon';
import CustomerTags from '../shared/CustomerTags';
// eslint-disable-next-line import/no-unresolved
import BotIcon from 'images/bot.svg';
import DealIcon from 'images/new_design/deal.svg'

const FacebookProfileInfo = ({customer, howLongAgo, agentName}) => {
  const messengerStatusIcon = customer.last_messenger_message?.sent_by_retailer === true
    && customer.last_messenger_message?.date_read;

  const isReadMessenger = customer.unread_messenger_chat === true
    || customer.unread_messenger_messages > 0
    || customer["unread_messenger_message?"] === true;

  return (
    <div className="col-10 px-0">
      <div className="profile__name">
        {customer.first_name} {customer.last_name}
        &nbsp;&nbsp;
        <span className="fw-muted time-from float-right">
          &nbsp;&nbsp;
          {howLongAgo()}
        </span>
      </div>
      <div>
        <p className="assigned-customer text-truncate d-inlineblock">
          {messengerStatusIcon && <DoubleCheckIcon className="fill-blue mr-8" />}
          {agentName(customer.assigned_agent)}
        </p>
      </div>

      {customer.active_bot && (
        <img src={BotIcon} alt="bot icon" className="w-18 h-18 mr-8" />
      )}
      {customer.has_deals && (
        <img src={DealIcon} alt="reminder icon" className="w-18 h-18" />
      )}
      {isReadMessenger && (
        <span className="float-right unread-messages rounded-pill float-right">
          <p className="m-0">{customer.unread_messenger_messages > 0 && customer.unread_messenger_messages}</p>
        </span>
      )}
      <div className="mt-15 row no-gutters">
        {customer.tags.length > 0 && <CustomerTags tags={customer.tags} />}
      </div>
    </div>
  )
};

export default FacebookProfileInfo;
