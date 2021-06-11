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

const FunnelDealDelete = ({ isOpen, openDeleteDeal, deleteDeal }) => (
  <Modal
    isOpen={isOpen}
    style={customStyles}
    ariaHideApp={false}
  >
    <button type="button" onClick={openDeleteDeal} className="f-right">Cerrar</button>
    <div className="row">
      <h4 className="mt-0 mb-15">Borrar negocio</h4>
    </div>

    <div className="row">
      <button type="button" className="py-5 px-15 funnel-btn btn--destroy" onClick={deleteDeal}>Borrar Negocio</button>
    </div>

  </Modal>
);

export default FunnelDealDelete;
