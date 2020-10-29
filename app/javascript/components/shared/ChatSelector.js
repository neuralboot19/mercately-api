import React from 'react'
import ChatListItem from './ChatListItem';

const ChatSelector = ({ chatType, currentCustomer, customers, handleLoadMoreOnScrollToBottom, handleOpenChat }) => {
  return (
    <div className="chat__selector" onScroll={(e) => handleLoadMoreOnScrollToBottom(e)}>
      {customers.map((customer, index) =>
        <ChatListItem
          key={index}
          currentCustomer={currentCustomer}
          customer={customer}
          handleOpenChat={handleOpenChat}
          chatType={chatType}
        />)}
    </div>
  )
}

export default ChatSelector;
