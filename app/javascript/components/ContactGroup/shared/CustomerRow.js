import React, { useRef } from 'react';

const CustomerRow = ({
  customer,
  onChange
}) => {
  const renderTags = (tags) => (
    tags.map((tag) => (
      <b key={tag.id} className="cookie cookie--blue fs-12 m-2 d-inline-block">
        {tag.tag}
      </b>
    ), this)
  );

  return (
    <div className="box">
      <div className="row">
        <div className="col-xs-12">
          <div className="separator" />
        </div>
        <div className="col-xs-1">
          <input type="checkbox" className="d-inline-block my-2" value={customer.id} onChange={onChange} />
        </div>
        <div className="col-xs-10 col-md-3">
          {customer.name}
        </div>
        <div className="col-xs-10 col-md-3">
          {customer.email}
        </div>
        <div className="col-xs-10 col-md-3">
          {customer.phone}
        </div>
        <div className="col-xs-10 col-md-2">
          {customer.tags && renderTags(customer.tags)}
        </div>
      </div>
    </div>
  );
};

export default CustomerRow;
