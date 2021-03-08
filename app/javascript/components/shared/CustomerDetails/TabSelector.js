import React from 'react';

const TabSelector = ({
  showUserDetails,
  showCustomFields,
  showIntegrationSettings,
  onClickUserDetails,
  onClickCustomerFields,
  onClickIntegrationSettings
}) => {
  const tabIconStyles = {
    active: {
      color: '#00B4FF'
    },
    inactive: {
      color: 'gray'
    }
  };
  const tabStyles = {
    active: {
      borderBottom: '2px solid #00B4FF'
    },
    inactive: {}
  };

  return (
    <div className="box px-5">
      <div className="row">
        <div
          className="col-xs-4 t-center py-5"
          style={showUserDetails === 'block' ? tabStyles.active : tabStyles.inactive}
        >
          <div className="tooltip-top">
            <i
              className="m-10 fas fa-user cursor-pointer"
              style={showUserDetails === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
              onClick={() => onClickUserDetails()}
            />
            <div className="tooltiptext bottom-100 tootip-text-customer-chat-column">Detalles</div>
          </div>
        </div>

        <div
          className="col-xs-4 t-center py-5"
          style={showCustomFields === 'block' ? tabStyles.active : tabStyles.inactive}
        >
          <div className="tooltip-top">
            <i
              className="m-10 far fa-address-card cursor-pointer"
              style={showCustomFields === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
              onClick={() => onClickCustomerFields()}
            />
            <div className="tooltiptext bottom-100 tootip-text-customer-chat-column">Campos Personalizados</div>
          </div>
        </div>
        <div
          className="col-xs-4 t-center py-5"
          style={showIntegrationSettings === 'block' ? tabStyles.active : tabStyles.inactive}
        >
          <div className="tooltip-top">
            <i
              className="m-10 fas fa-link cursor-pointer"
              style={showIntegrationSettings === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
              onClick={onClickIntegrationSettings}
            />
            <div className="tooltiptext bottom-100">Integraciones</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TabSelector;
