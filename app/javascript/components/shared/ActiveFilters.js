import React from 'react';

const ActiveFilters = ({ cleanFilters }) => (
  <div className="d-flex p-relative mb-5 mr-10">
    <div className="c-secondary fs-15">
      <span>Tienes filtros activos</span>
    </div>
    <div className="remove-filters fs-14">
      <i className="fas fa-times-circle mr-5"></i>
      <span onClick={cleanFilters}>Quitar filtros</span>
    </div>
  </div>
);

export default ActiveFilters;
