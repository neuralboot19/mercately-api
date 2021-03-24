import React from 'react';

const id = window.location.pathname.split('/')[4];

const TabSelector = ({
  tabSelected,
  changeTab
}) => {
  const tabClasses = {
    active: "worm__btn worm__btn--selected",
    inactive: "worm__btn"
  };

  return (
    <>
      <div className="col-xs-12 col-md-6">
        <div className={tabSelected === 'customers' ? tabClasses.active : tabClasses.inactive}>
          <a onClick={() => changeTab('customers')}>Clientes</a>
        </div><div
          className={tabSelected === 'selectedCustomers' ? tabClasses.active : tabClasses.inactive}
        >
          <a onClick={() => changeTab('selectedCustomers')}>Clientes agregados al grupo</a>
        </div>
      </div>
      { window.location.pathname.split('/').pop() === 'edit'
          && (
            <div className="col-xs-12 col-md-6 t-right">
              <div className="index__ctas f-right">
                <a href={`/retailers/${ENV.SLUG}/contact_groups/${id}/import_update`} className="btn btn--cta d-inline-block">
                  <i className="fas fa-plus mr-5" />
                  Importar clientes a este grupo
                </a>
              </div>
            </div>
          )}
    </>
  );
};

export default TabSelector;
