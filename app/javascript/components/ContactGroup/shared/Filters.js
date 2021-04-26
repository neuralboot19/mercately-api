import React from 'react';
import Select from 'react-select';

const Filters = ({
  search,
  tags,
  onSearchChange,
  onTagsChange
}) => (
  <div className="box mb-24 mt-12">
    <div className="row">
      <div className="col-xs-6 p-0">
        <div className="box bordered-box px-8 pt-8 pb-12">
          <div className="row">
            <div className="col-xs-12 px-0 fs-14 no-style-filter">Buscar por:</div>
            <div className="col-xs-12 px-0 mt-5 fs-14 no-style-filter p-relative">
              <input
                name="q[name_phone_email_cont]"
                className="input-100 search-field"
                placeholder="Busca por nombres, email o teléfono"
                value={search}
                style={{ boxSizing: 'border-box' }}
                onChange={onSearchChange}
              />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-12 px-0 fs-14 mt-5 no-style-filter">Etiquetas:</div>
            <div className="col-xs-12 px-0 mt-5 fs-14 no-style-filter p-relative">
              <Select
                onChange={onTagsChange}
                options={tags}
                isMulti="true"
                name="q[customer_tags_tag_id_in_all]"
                placeholder="Buscar por etiquetas"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
);

export default Filters;
