import React from 'react';
import PropTypes from 'prop-types';

const ReminderTemplateItem = ({
  template,
  onMobile,
  setTemplateType,
  getCleanTemplate,
  selectTemplate
}) => (
  <div className="d-flex justify-content-between mb-8" key={template.id}>
    <div className="fs-14 input-from-backend">
      <p className="text-gray-dark">
        {`[${setTemplateType(template.template_type)}] `}
        {getCleanTemplate(template.text)}
      </p>
    </div>
    <div>
      <a className="border-8 bg-blue text-white p-12 fs-12" onClick={() => selectTemplate(template)}>Seleccionar</a>
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
