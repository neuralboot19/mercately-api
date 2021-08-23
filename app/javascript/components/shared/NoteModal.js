import React, { forwardRef, useImperativeHandle, useState } from 'react';
import Modal from 'react-modal';
// eslint-disable-next-line import/no-unresolved
import { registerLocale } from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import es from 'date-fns/locale/es';
import CloseIcon from '../icons/CloseIcon';
import modalCustomStyles from '../../util/modalCustomStyles';

registerLocale('es', es);

const NoteModal = forwardRef(({
  onMobile,
  cancelNote,
  submitNote,
  isNoteModalOpen,
  toggleNoteModal
}, noteTextRef) => {
  const [currentValue, setCurrentValue] = useState('');
  const [currentValueLength, setCurrentValueLength] = useState(0);

  const handleChange = (event) => {
    const inputVal = event.target.value;
    setCurrentValue(inputVal);
    setCurrentValueLength(inputVal.length);
  };

  const clearValue = () => {
    setCurrentValue('');
    setCurrentValueLength(0);
  };

  useImperativeHandle(noteTextRef, () => ({
    clearValue,
    value: currentValue
  }));

  return (
    <Modal appElement={document.getElementById("react_content")} isOpen={isNoteModalOpen} style={modalCustomStyles(onMobile)}>
      <div className="input-from-backend h-100p">
        <div className="d-flex justify-content-between">
          <div>
            <p className={`font-weight-bold ${onMobile ? "fs-16 mt-0" : "fs-24 mt-0"}`}>
              Crear Nota
            </p>
          </div>
          <div className="">
            <a className="px-8" onClick={() => toggleNoteModal()}>
              <CloseIcon className="fill-dark" />
            </a>
          </div>
        </div>
        <textarea id="note-textarea" className="w-100" maxLength={500} value={currentValue} onChange={handleChange} />
        {currentValueLength} / 500
        <div className="d-flex justify-content-center justify-content-md-end mt-30">
          <div className={onMobile ? "mr-5" : "mr-15"}>
            <a className="border-8 bg-light text-gray-dark p-12 border-gray" onClick={() => cancelNote()}>Cancelar</a>
          </div>
          <div className="">
            <a className="border-8 bg-blue text-white p-12" onClick={() => submitNote()}>Guardar</a>
          </div>
        </div>
      </div>
    </Modal>
  );
});

export default NoteModal;
