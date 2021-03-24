import React from 'react';
import ReactPaginate from 'react-paginate';

import Filters from './shared/Filters';
import CustomerRow from './shared/CustomerRow';

const SelectedCustomersTabContent = ({
  selectAll,
  selectedCustomers,
  search,
  onSearchSelectedCustomersChange,
  onChangeSelectedCustomerCheckbox,
  onSelectedCustomersTagsChange,
  tabSelected,
  unselectCustomers,
  totalPages,
  tags,
  changeSelectedCustomersPage,
  currentSelectedCustomersPage
}) => {
  const renderCustomers = () => (
    selectedCustomers.map((customer) => (
      <CustomerRow
        key={customer.id}
        customer={customer}
        onChange={onChangeSelectedCustomerCheckbox}
      />
    ), this)
  );

  return (
    <div className="col-xs-12" style={{ display: tabSelected === 'selectedCustomers' ? 'block' : 'none' }}>
      <div className="row">
        <div className="col-xs-12 p-0">
          <br />
          <b>Clientes agregados al grupo</b>
          <br />
          <Filters
            search={search}
            onSearchChange={onSearchSelectedCustomersChange}
            onTagsChange={onSelectedCustomersTagsChange}
            tags={tags}
          />
        </div>
      </div>
      <div id="items-header" className="row">
        <div className="col-xs-1">
          <input id="selectAll--selected_customers" type="checkbox" onChange={selectAll} />
        </div>
        <div className="col-xs-10 col-md-3">
          Nombre
        </div>
        <div className="col-xs-10 col-md-3">
          Email
        </div>
        <div className="col-xs-10 col-md-3">
          Teléfono
        </div>
        <div className="col-xs-10 col-md-2">
          Etiquetas
        </div>
      </div>
      <div id="selected_customers">
        {selectedCustomers && renderCustomers() }
      </div>
      <div className="row">
        <div className="col-xs-12 mt-16">
          <a className="btn btn--cta hide-on-tablet-and-down" href="#!" onClick={unselectCustomers}>
            <i className="fas fa-minus mr-5" />
            Remover del grupo
          </a>
        </div>
      </div>
      <div className="t-center">
        {
          totalPages > 1
            && (
              <ReactPaginate
                pageCount={totalPages}
                pageRangeDisplayed={5}
                marginPagesDisplayed={2}
                previousLabel="Anterior"
                nextLabel="Siguiente"
                onPageChange={changeSelectedCustomersPage}
                forcePage={currentSelectedCustomersPage}
                containerClassName="pagination"
                pageClassName="page"
                activeClassName="page current"
                previousClassName="previous"
                nextClassName="next"
              />
            )
        }
      </div>
    </div>
  );
};

export default SelectedCustomersTabContent;
