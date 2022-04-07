import React, {
  forwardRef,
  useImperativeHandle,
  useState
} from 'react';
import Modal from 'react-modal';
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';

const ModalWindow = forwardRef(({
  title,
  customStyle={},
  customClass='',
  ...props
}, categoryRef) => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleModal = () => (
    setIsOpen(!isOpen)
  );

  useImperativeHandle(categoryRef, () => ({
    toggleModal
  }));

  return (
    <Modal
      isOpen={isOpen}
      style={modalCustomStyles(window.innerWidth < 768, customStyle)}
      ariaHideApp={false}
    >
      <div className="d-flex justify-content-between mt-20">
        <div>
          <p className="modal-title fs-24 ml-15">{title}</p>
        </div>
        <div className='mr-20'>
          <a className="px-8" type="button" onClick={toggleModal}>
            <CloseIcon className="fill-dark" />
          </a>
        </div>
      </div>
      <div className='divider-line'></div>
      {props.children}
    </Modal>
  );
});

export default ModalWindow;
