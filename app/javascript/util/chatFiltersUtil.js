const checkFilters = (customer, filters, chatType) => {
  if (filters.searchString === '' && filters.agent === 'all' && filters.type === 'all' && filters.tag === 'all'
    && filters.tab === 'all' && status === 'all')
    return true;

  let matchFilters = [];
  if (filters.searchString) {
    const search = filters.searchString.toLowerCase().split(' ');
    let values = [customer.first_name, customer.last_name, customer.whatsapp_name, customer.email, customer.phone];
    values = values.filter(elem => elem);

    matchFilters.push(values.some(item => includeFilter(search, item)));
  }

  if (filters.agent !== 'all') {
    if (filters.agent === 'not_assigned') {
      matchFilters.push(!customer.assigned_agent.id);
    } else {
      matchFilters.push(customer.assigned_agent.id == filters.agent);
    }
  }

  if (filters.type !== 'all') {
    if (chatType === 'facebook') {
      matchFilters.push(readOrNotFacebook(customer, filters));
    } else if (chatType === 'whatsapp') {
      matchFilters.push(readOrNotWhatsapp(customer, filters));
    }
  }

  if (filters.tag !== 'all') {
    const tags = customer.tags.filter(tag => tag.id == filters.tag);

    matchFilters.push(tags.length > 0);
  }

  if (filters.status !== 'all') {
    matchFilters.push(customer.status_chat === filters.status);
  }

  if (filters.tab !== 'all') {
    matchFilters.push(checkStatusByTab(customer, filters.tab));
  }

  return matchFilters.indexOf(false) < 0;
};

const includeFilter = (search, item) => (
  search.some((elem) => elementWithValue(item, elem))
);

const elementWithValue = (elem, item) => (
  elem.includes(item.toLowerCase())
);

const readOrNotFacebook = (customer, filters) => {
  let isTrue = false;

  if (filters.type === 'no_read') {
    isTrue = customer.unread_messenger_chat === true || customer.unread_messenger_messages > 0 ||
      customer['unread_message?'] === true;
  } else if (filters.type === 'read') {
    isTrue = customer.unread_messenger_chat === false && customer.unread_messenger_messages === 0 &&
      customer['unread_message?'] === false;
  }

  return isTrue;
}

const readOrNotWhatsapp = (customer, filters) => {
  let isTrue = false;

  if (filters.type === 'no_read') {
    isTrue = customer.unread_whatsapp_chat === true || customer.unread_whatsapp_messages > 0 ||
      customer['unread_whatsapp_message?'] === true;
  } else if (filters.type === 'read') {
    isTrue = customer.unread_whatsapp_chat === false && customer.unread_whatsapp_messages === 0 &&
      customer['unread_whatsapp_message?'] === false;
  }

  return isTrue;
}

const checkStatusByTab = (customer, tab) => {
  let ok = false;

  switch (tab) {
    case 'pending':
      ok = ['new_chat', 'open_chat', 'in_process'].includes(customer.status_chat);
      break;
    case 'resolved':
      ok = customer.status_chat === tab;
      break;
  }

  return ok;
}

export default {
  checkFilters,
  includeFilter,
  elementWithValue,
  readOrNotFacebook,
  readOrNotWhatsapp,
  checkStatusByTab
};
