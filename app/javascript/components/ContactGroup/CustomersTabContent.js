import React from 'react';
import ReactPaginate from 'react-paginate';

import Filters from './shared/Filters';
import CustomerRow from './shared/CustomerRow';

const CustomersTabContent = ({
  selectAll,
  customers,
  search,
  onSearchChange,
  onChangeCustomerCheckbox,
  tabSelected,
  onCustomersTagsChange,
  selectCustomers,
  totalPages,
  tags,
  changeCustomersPage,
  currentCustomersPage
}) => {
  const renderCustomers = () => (
    customers.map((customer) => (
      <CustomerRow
        key={customer.id}
        onChange={onChangeCustomerCheckbox}
        customer={customer}
      />
    ), this)
  );

  return (
    <div className="col-xs-12" style={{ display: tabSelected === 'customers' ? 'block' : 'none' }}>
      <div className="row">
        <div className="col-xs-12 p-0">
          <br />
          <b>Selección de clientes</b>
          <br />
          <Filters
            search={search}
            onSearchChange={onSearchChange}
            onTagsChange={onCustomersTagsChange}
            tags={tags}
          />
        </div>
      </div>
      <div id="items-header" className="row">
        <div className="col-xs-1">
          <input id="selectAll--customers" type="checkbox" onChange={selectAll} />
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
      <div id="customers">
        {customers && renderCustomers() }
      </div>
      <div className="row">
        <div className="col-xs-12 mt-16">
          <a className="btn btn--cta hide-on-tablet-and-down" href="#!" onClick={selectCustomers}>
            <i className="fas fa-plus mr-5" />
            Agregar al grupo
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
                onPageChange={changeCustomersPage}
                forcePage={currentCustomersPage}
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

export default CustomersTabContent;
