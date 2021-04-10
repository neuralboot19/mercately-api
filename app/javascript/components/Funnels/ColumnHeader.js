/* eslint-disable react/jsx-props-no-spreading */
import React from "react";

const ColumnHeader = ({
  provided,
  dealInfo,
  openCreateDeal,
  openDeleteStep
}) => (
  <div className="column-header" {...provided.dragHandleProps}>
    <div className="column-title">
      <h1>{dealInfo.title}</h1>
      <div className="column-title-content">
        <p>
          {dealInfo.deals}
          {" "}
          {dealInfo.deals === 1 ? "negociación" : "negociaciones"}
        </p>
      </div>

      <div
        className="tooltip-top-column add"
        onClick={() => openCreateDeal(
          dealInfo.internal_id,
          dealInfo.id,
          dealInfo.r_internal_id
        )}
      >
        <i className="fas fa-plus"></i>
        <div className="tooltiptext-column">Crear Negociación</div>
      </div>

      <div
        className="tooltip-top-column-erase erase"
        onClick={() => openDeleteStep(dealInfo.id)}
      >
        <i className="fas fa-trash-alt"></i>
        <div className="tooltiptext-column-erase">
          Borrar etapa
          <br />
          de negociación
        </div>
      </div>
    </div>
  </div>
);

export default ColumnHeader;
