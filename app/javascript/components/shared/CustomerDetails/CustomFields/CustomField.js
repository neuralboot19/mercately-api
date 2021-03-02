import React, {
  useEffect,
  useRef,
  useState
} from "react";
import DatePicker, { registerLocale } from "react-datepicker";
import es from 'date-fns/locale/es';
import SelectableCustomField from "./SelectableCustomField";
import "react-datepicker/dist/react-datepicker.css";

const _ = require('lodash');

registerLocale('es', es);

const CustomField = ({
  fieldValue,
  customField,
  onSubmit
}) => {
  const [currentFieldValue, setCurrentFieldValue] = useState(fieldValue);
  const fieldType = customField.field_type;

  useEffect(() => {
    setCurrentFieldValue(fieldValue);
  }, [fieldValue]);

  const isMounted = useRef(false);

  useEffect(() => {
    if (isMounted.current
      && (['boolean', 'date', 'list'].includes(fieldType))
      && currentFieldValue !== fieldValue
    ) {
      onSubmit(currentFieldValue, customField);
    } else {
      isMounted.current = true;
    }
  }, [currentFieldValue]);

  const handleCustomFieldSubmit = () => {
    onSubmit(fieldType === 'float' ? addPaddingZeroes(currentFieldValue) : currentFieldValue, customField);
  };

  const handleSelectTypeCustomFieldChange = (selection) => {
    setCurrentFieldValue(selection.value);
  };

  const buildOptions = (options) => {
    let hash = { value: '', label: '' };

    return options.reduce((arr, elem) => {
      hash = { value: elem, label: elem };

      arr.push(hash);

      return arr;
    }, []);
  };

  const handleDateTypeCustomFieldChange = (date) => {
    setCurrentFieldValue(date.toISOString());
  };

  const handleBooleanCustomFieldChange = (evt) => {
    const { value } = evt.target;
    setCurrentFieldValue(value);
    onSubmit(currentFieldValue, customField);
  };

  const filterIntegerInput = (value) => value.replace(/[^0-9]/, '');

  const isNumeric = (value) => {
    const regExp = /^\d*(\.\d*)?$/;
    return regExp.test(value);
  };

  const addPaddingZeroes = (value) => {
    let newValue = value;
    if (_.first(value) === '.') {
      newValue = `0${newValue}`;
    }
    if (_.last(value) === '.') {
      newValue = `${newValue}0`;
    }
    return newValue;
  };

  const filterFloatValue = (value) => value.replace(/[^0-9.]/, '');

  const handleCustomFieldChange = (evt) => {
    let filteredValue;
    const { value } = evt.target;
    switch (fieldType) {
      case 'integer': {
        filteredValue = filterIntegerInput(value);
        break;
      }
      case 'float': {
        if (isNumeric(value)) {
          filteredValue = filterFloatValue(value);
        } else {
          filteredValue = currentFieldValue;
        }
        break;
      }
      default: {
        filteredValue = value;
      }
    }
    setCurrentFieldValue(filteredValue);
  };

  switch (customField.field_type) {
    case 'list': {
      return (
        <SelectableCustomField
          selected={currentFieldValue}
          handleSelectChange={handleSelectTypeCustomFieldChange}
          options={buildOptions(customField.list_options)}
        />
      );
    }
    case 'date': {
      return (
        <DatePicker
          selected={Date.parse(currentFieldValue)}
          onChange={(date) => handleDateTypeCustomFieldChange(date)}
          locale="es"
          yearDropdownItemNumber={5}
          dateFormat="yyyy-MM-dd"
          showYearDropdown
        />
      );
    }
    case 'integer':
    case 'float':
      return (
        <input
          fieldtype={customField.field_type}
          value={currentFieldValue}
          onChange={handleCustomFieldChange}
          onBlur={() => handleCustomFieldSubmit(customField)}
        />
      );
    case 'boolean':
      return (
        <>
          Sí
          <input
            type="radio"
            value="true"
            checked={currentFieldValue === "true"}
            onChange={handleBooleanCustomFieldChange}
          />
          &nbsp;
          No
          <input
            type="radio"
            value="false"
            checked={currentFieldValue === "false"}
            onChange={handleBooleanCustomFieldChange}
          />
        </>
      );
    default:
      return (
        <textarea
          value={currentFieldValue}
          onChange={handleCustomFieldChange}
          className="editable_field"
          onBlur={() => handleCustomFieldSubmit(customField)}
          placeholder={customField.name}
        />
      );
  }
};

export default CustomField;
