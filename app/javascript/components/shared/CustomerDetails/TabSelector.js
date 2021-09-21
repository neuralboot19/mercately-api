import React from 'react';

const TabSelector = ({
  showUserDetails,
  showCustomFields,
  showAutomationSettings,
  showIntegrationSettings,
  showNotes,
  onClickUserDetails,
  onClickCustomerFields,
  onClickAutomationSettings,
  onClickIntegrationSettings,
  onClickNotes
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
      <div className="customer_icon_holder">
        <div className="container">
          <div className="row justify-content-center m-0">
            <div
              className="col-2 t-center py-5"
              style={showUserDetails === 'block' ? tabStyles.active : tabStyles.inactive}
            >
              <div className="tooltip-top">
                <i
                  className="fas fa-user cursor-pointer"
                  style={showUserDetails === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
                  onClick={() => onClickUserDetails()}
                />
                <div className="tooltiptext bottom-100 tootip-text-customer-chat-column">Detalles</div>
              </div>
            </div>

            <div
              className="col-2 t-center py-5"
              style={showCustomFields === 'block' ? tabStyles.active : tabStyles.inactive}
            >
              <div className="tooltip-top">
                <i
                  className="far fa-address-card cursor-pointer"
                  style={showCustomFields === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
                  onClick={() => onClickCustomerFields()}
                />
                <div className="tooltiptext bottom-100 tootip-text-customer-chat-column">Campos Personalizados</div>
              </div>
            </div>
            <div
              className="col-2 t-center py-5"
              style={showAutomationSettings === 'block' ? tabStyles.active : tabStyles.inactive}
            >
              <div className="tooltip-top">
                <i
                  className="fas fa-robot cursor-pointer"
                  style={showAutomationSettings === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
                  onClick={onClickAutomationSettings}
                />
                <div className="tooltiptext bottom-100">Automatizaciones</div>
              </div>
            </div>
            <div
              className="col-2 t-center py-5"
              style={showIntegrationSettings === 'block' ? tabStyles.active : tabStyles.inactive}
            >
              <div className="tooltip-top">
                <i
                  className="fas fa-link cursor-pointer"
                  style={showIntegrationSettings === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
                  onClick={onClickIntegrationSettings}
                />
                <div className="tooltiptext bottom-100">Integraciones</div>
              </div>
            </div>
            <div
              className="col-2 t-center py-5"
              style={showNotes === 'block' ? tabStyles.active : tabStyles.inactive}
            >
              <div className="tooltip-top">
                <i
                  className="fas fa-sticky-note cursor-pointer"
                  style={showNotes === 'block' ? tabIconStyles.active : tabIconStyles.inactive}
                  onClick={onClickNotes}
                />
                <div className="tooltiptext bottom-100">Notas</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TabSelector;
