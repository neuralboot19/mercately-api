import React from 'react';
// eslint-disable-next-line import/no-unresolved
import CloseIcon from 'images/close.svg';

const ActiveFilters = ({ cleanFilters }) => (
  <div className="cursor-pointer text-center mb-16" onClick={cleanFilters}>
    <span className="mr-8 variations-label-bold">Limpiar filtros activos</span>
    <img src={CloseIcon} alt="close icon" className="remove-filters-icon" />
  </div>
);

export default ActiveFilters;
