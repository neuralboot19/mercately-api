import React from 'react';

const NavStatusChat = ({
  tab,
  handleAddOptionToFilter,
  loadingMoreCustomers
}) => (
  <div className="row t-center fs-14 ml-0 navs-container">
    <div className={`col-5 navs-status ${tab === 'pending' && 'active'} ${loadingMoreCustomers && 'disabled-tab'}`}
      onClick={ () => handleAddOptionToFilter('pending', 'tab') }>
      <span>Pendientes</span>
    </div>
    <div className={`col-4 navs-status ${tab === 'resolved' && 'active'} ${loadingMoreCustomers && 'disabled-tab'}`}
      onClick={ () => handleAddOptionToFilter('resolved', 'tab') }>
      <span>Resueltos</span>
    </div>
    <div className={`col-3 navs-status ${tab === 'all' && 'active'} ${loadingMoreCustomers && 'disabled-tab'}`}
      onClick={ () => handleAddOptionToFilter('all', 'tab') }>
      <span>Todos</span>
    </div>
  </div>
);

export default NavStatusChat;
