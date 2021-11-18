import React from 'react';
import CheckIcon from '../icons/CheckIcon';
import DoubleCheckIcon from '../icons/DoubleCheckIcon';
import CustomerTags from '../shared/CustomerTags';
// eslint-disable-next-line import/no-unresolved
import BotIcon from 'images/bot.svg';
// eslint-disable-next-line import/no-unresolved
import ReminderIcon from 'images/new_design/reminder-chat.svg';
import DealIcon from 'images/new_design/deal.svg'

const WhatsAppProfileInfo = ({customer, howLongAgo, agentName}) => {
  const messageStatusIcon = (message) => {
    switch (message.status) {
      case 'error':
        return <i className="fas fa-exclamation-circle mr-8" />;
      case 'sent':
        return <CheckIcon className="fill-gray mr-8" />;
      case 'delivered':
        return <DoubleCheckIcon className="fill-gray mr-8" />;
      case 'read':
        return <DoubleCheckIcon className="fill-blue mr-8" />;
      default:
        if (message.content_type === 'text') {
          return <CheckIcon className="fill-gray mr-8" />;
        }

        return <i className={`fas fa-sync black`} />;
    }
  }

  const hasWhatsappNameOrPhone = () => (customer.whatsapp_name
    ? customer.whatsapp_name
    : customer.phone);

  const getProfileName = customer.first_name && customer.last_name
      ? `${customer.first_name} ${customer.last_name}`
      : hasWhatsappNameOrPhone();

  const whatsappStatusIcon = customer.last_whatsapp_message?.direction === 'outbound'
    && customer['handle_message_events?'] === true;

  const isReadWhatsapp = customer.unread_whatsapp_chat === true
    || customer.unread_whatsapp_messages > 0
    || customer['unread_whatsapp_message?'] === true;

  return (
    <div className="col-10 px-0">
      <div className="profile__name">
        {getProfileName}
        &nbsp;&nbsp;
        <span className="fw-muted time-from float-right">
          {howLongAgo()}
          <br />
        </span>

      </div>
      <div>
        <p className="assigned-customer text-truncate">
          {whatsappStatusIcon && messageStatusIcon(customer.last_whatsapp_message)}
          {agentName(customer.assigned_agent)}
        </p>
      </div>

      <div className="">
        {customer.active_bot && (
          <img src={BotIcon} alt="bot icon" className="w-18 h-18 mr-12" />
        )}
        {customer.has_pending_reminders && (
          <img src={ReminderIcon} alt="reminder icon" className="w-18 h-18 mr-12" />
        )}
        {customer.has_deals && (
          <img src={DealIcon} alt="reminder icon" className="w-18 h-18" />
        )}
        {isReadWhatsapp && (
          <span className="float-right unread-messages rounded-pill float-right">
            <p className="m-0">{customer.unread_whatsapp_messages > 0 && customer.unread_whatsapp_messages}</p>
          </span>
        )}
      </div>
      <div className="mt-15 row no-gutters">
        {customer.tags.length > 0 && <CustomerTags tags={customer.tags} />}
      </div>
    </div>
  )
};

export default WhatsAppProfileInfo;
