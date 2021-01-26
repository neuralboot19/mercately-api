import React from 'react';
import PropTypes from 'prop-types';

const ReminderTemplateItem = ({
  template,
  onMobile,
  setTemplateType,
  getCleanTemplate,
  selectTemplate
}) => (
  <div className="row" key={template.id}>
    <div className={onMobile ? "col-md-10 fs-10" : "col-md-10"}>
      <p>
        {`[${setTemplateType(template.template_type)}] `}
        {getCleanTemplate(template.text)}
      </p>
    </div>
    <div className="col-md-2">
      <button type="submit" onClick={() => selectTemplate(template)}>Seleccionar</button>
    </div>
  </div>
);

ReminderTemplateItem.propTypes = {
  template: PropTypes.shape({
    id: PropTypes.number.isRequired,
    retailer_id: PropTypes.number.isRequired,
    text: PropTypes.string.isRequired,
    status: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    updated_at: PropTypes.string.isRequired,
    template_type: PropTypes.string.isRequired,
    gupshup_template_id: PropTypes.string
  }).isRequired,
  onMobile: PropTypes.bool.isRequired,
  setTemplateType: PropTypes.func.isRequired,
  getCleanTemplate: PropTypes.func.isRequired,
  selectTemplate: PropTypes.func.isRequired
};

export default ReminderTemplateItem;
