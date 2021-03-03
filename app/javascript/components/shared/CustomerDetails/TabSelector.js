import React from 'react';

const TabSelector = ({
  showUserDetails,
  showCustomFields,
  onClickUserDetails,
  onClickCustomerFields
}) => {
  const tabIconStyles = {
    active: {
      color: '#00B4FF'
    },
    inactive: {
      color: 'gray'
    }
  };

  return (
    <div className="customer_box">
      <div className="tooltip d-inline">
        <i
          className="m-10 fas fa-user cursor-pointer"
          style={showUserDetails === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
          onClick={() => onClickUserDetails()}
        />
        <div className="tooltiptext tootip-text-customer-chat-column">Detalles</div>
      </div>

      <div className="tooltip d-inline">
        <i
          className="m-10 far fa-file-alt cursor-pointer"
          style={showCustomFields === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
          onClick={() => onClickCustomerFields()}
        />
        <div className="tooltiptext tootip-text-customer-chat-column">Campos Personalizados</div>
      </div>
    </div>
  );
};

export default TabSelector;
