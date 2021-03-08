import React from 'react';

const IntegrationsTabContent = ({
  customer,
  onClickUserDetails,
  handleCheckboxChange,
  showIntegrationSettings
}) => (
  <div className="custome_fields" style={{ display: showIntegrationSettings }}>
    <div className="details_holder">
      <span>Integraciones</span>
    </div>
    <div className="bordered-container">
      { ENV.HUBSPOT_INTEGRATED ? (
        <>
          <div className="t-center">
            <span>
              <i className="fab fa-hubspot pr-6" style={{ color: '#FF7A59' }} />
              {customer.hs_active ? (
                'Contacto sincronizado con Hubspot'
              ) : (
                'Contacto desconectado de Hubspot'
              )}
            </span>
          </div>
          {customer.email !== '' && customer.email !== null ? (
            <div className="t-center my-16">
              <input
                id="hs_active"
                className="d-none"
                type="checkbox"
                onChange={handleCheckboxChange}
                checked={customer.hs_active === true}
                name="hs_active"
              />
              <label htmlFor="hs_active" className="btn btn--cta">
                {customer.hs_active ? (
                  'Retirar sincronización'
                ) : (
                  'Sincronizar contacto'
                )}
              </label>
            </div>
          ) : (
            <div className="t-center my-16">
              Este contacto no existe en hubspot. Para sincronizarlo introduce un email
              <br />
              <br />
              <a className="btn btn--cta" onClick={onClickUserDetails}>
                Añadir email
              </a>
            </div>
          )}
          {customer.hs_id && (
            <div className="t-center mb-16 mt-24">
              <a
                href={`https://app.hubspot.com/contacts/${ENV.HS_ID}/contact/${customer.hs_id}/`}
                target="_blank"
                className="fs-sm-and-down-8 fs-12 btn-btn btn-submit"
              >
                Ver en Hubspot
              </a>
            </div>
          )}
        </>
      ) : (
        <div className="t-center">
          <span>
            <i className="fab fa-hubspot c-black pr-6" />
            No estás integrado con Hubspot
            <br />
            <br />
            <a href={ENV.HUBSPOT_AUTH_URL} className="fs-sm-and-down-8 fs-12 btn-btn btn-submit">
              Conectar con Hubspot
            </a>
          </span>
        </div>
      )}
    </div>
  </div>
);

export default IntegrationsTabContent;
