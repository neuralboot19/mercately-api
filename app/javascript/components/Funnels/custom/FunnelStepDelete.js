import React from 'react';
import Modal from 'react-modal';

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

const FunnelStepDelete = ({ isOpen, openDeleteStep, deleteStep }) => (
  <Modal
    isOpen={isOpen}
    style={customStyles}
    ariaHideApp={false}
  >
    <button type="button" onClick={openDeleteStep} className="f-right">Cerrar</button>
    <div className="row">
      <h4 className="my-0">Borrar etapa de negocio</h4>
    </div>
    <div className="mb-15">
      <p className="my-0 index__desc">Al borrar la etapa de negocio, eliminarás todas las negociaciones asociadas</p>
      <p className="my-0 index__desc">Estas seguro?</p>
    </div>

    <div className="row">
      <button type="button" className="py-5 px-15 funnel-btn btn--destroy" onClick={deleteStep}>Borrar Etapa</button>
    </div>

  </Modal>
);

export default FunnelStepDelete;
