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

const initialFieldValue = '';

const CustomField = ({
  fieldValue,
  customField,
  onSubmit
}) => {
  const [currentFieldValue, setCurrentFieldValue] = useState(initialFieldValue);

  useEffect(() => {
    setCurrentFieldValue(fieldValue || initialFieldValue);
  }, [fieldValue]);

  const isMounted = useRef(false);

  useEffect(() => {
    if (isMounted.current
      && (['boolean', 'date', 'list'].includes(customField.field_type))
      && currentFieldValue !== fieldValue
    ) {
      onSubmit(currentFieldValue, customField);
    } else {
      isMounted.current = true;
    }
  }, [currentFieldValue]);

  const handleCustomFieldSubmit = () => {
    onSubmit(customField.field_type === 'float' ? addPaddingZeroes(currentFieldValue) : currentFieldValue, customField);
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
    switch (customField.field_type) {
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
          className="custom-input"
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
          value={currentFieldValue}
          className="custom-input"
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
            onChange={handleCustomFieldChange}
          />
          &nbsp;
          No
          <input
            type="radio"
            value="false"
            checked={currentFieldValue === "false"}
            onChange={handleCustomFieldChange}
          />
        </>
      );
    default:
      return (
        <input
          value={currentFieldValue}
          className="custom-input"
          onChange={handleCustomFieldChange}
          onBlur={() => handleCustomFieldSubmit(customField)}
          placeholder={customField.name}
        />
      );
  }
};

export default CustomField;
