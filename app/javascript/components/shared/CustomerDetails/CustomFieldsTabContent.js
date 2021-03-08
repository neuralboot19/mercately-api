import React from 'react';
import CustomField from "./CustomFields/CustomField";

const CustomFieldsTabContent = ({
  customFields,
  customerFields,
  showCustomFields,
  updateCustomerField
}) => {
  const getCustomerField = (customField) => (
    customerFields.find((element) => element.customer_related_field.identifier === customField.identifier)
  );

  const renderCustomerFields = () => (
    customFields.map((customField) => {
      const field = getCustomerField(customField);
      return (
        <div key={customField.id}>
          <div>
            <p className="label inline-block">{`${customField.name}:`}</p>
          </div>
          <div>
            <CustomField
              key={customField.id}
              fieldValue={field?.data}
              customField={customField}
              onSubmit={updateCustomerField}
            />
          </div>
        </div>
      );
    }, this)
  );

  return (
    <div className="custome_fields" style={{ display: showCustomFields }}>
      <div className="details_holder">
        <span>Campos Personalizados</span>
      </div>
      <div>
        {customFields && renderCustomerFields() }
      </div>
    </div>
  );
};

export default CustomFieldsTabContent;
