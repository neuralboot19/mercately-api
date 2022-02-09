import React from "react";

const PlatformMessageCounter = ({
  icon,
  total,
  inbound,
  outbound,
  className = ''
}) => (
  <div className={`col-md-3 ${className}`}>
    <div className="p-24">
      <div className="stats-card-row-values pb-16">
        <img src={icon} className="stats-icon-platform" alt="" />
        <div className="stats-total-container">
          <span>Total</span>
          <span>{total}</span>
        </div>
      </div>
      <div className="stats-card-row-values">
        <span className="stats-card-label pb-8">Recibidos</span>
        <span className="stats-card-label pb-8">{inbound}</span>
      </div>
      <div className="stats-card-row-values">
        <span className="stats-card-label pb-0">Enviados</span>
        <span className="stats-card-label pb-0">{outbound}</span>
      </div>
    </div>
  </div>
);

export default PlatformMessageCounter;
