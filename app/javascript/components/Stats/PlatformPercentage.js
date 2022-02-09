import React from "react";

const PlatformPercentage = ({
  percentage,
  name,
  color,
  className = ''
}) => (
  <div className={`stats-chart-legend-item ${className}`}>
    <div className="stats-chart-legend-header">
      <span className="stats-chart-legend-dot" style={{ color }}>•</span>
      <span className="stats-chart-legend-label">{name}</span>
    </div>
    <span className="stats-chart-legend-value">
      {percentage}
      %
    </span>
  </div>
);

export default PlatformPercentage;
