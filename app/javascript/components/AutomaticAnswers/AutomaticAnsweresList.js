import React from 'react';
import { useDispatch } from 'react-redux';
import EditIcon from 'images/edit.svg';

import wsIcon from 'images/new_design/wa.png';
import msnIcon from 'images/new_design/msm.png';
import igIcon from 'images/new_design/ig.png';

import { deleteAutomaticAnswer } from '../../actions/automaticAnswers';

const AutomaticAnswerList = ({
  messages,
  noMessagesMsg,
  openEditAutomaticAnswerModal,
  openShowAutomaticAnswerModal
}) => {
  const dispatch = useDispatch();

  const removeAutomaticAnswer = (selectedMessage) => {
    if (confirm('¿Está seguro de borrar este mensaje?')) {
      dispatch(deleteAutomaticAnswer(selectedMessage.id));
    }
  };

  return (
  <>
    {!_.isEmpty(messages) ? (messages.map((message) => (
      <div key={message.id} className="no-min-height m-0 shadow-none no-border p-0 bg-transparent">
        <div className="card-header bg-transparent border-0 px-0 py-5" id={message.id}>
          <div className="mb-0 row text-center align-items-center">
            <div className="col-xl-4 col-md-4 my-8 pl-56 text-left">
              {message.message}
            </div>
            <div className="col-xl-2 col-md-2 d-none d-xl-block text-left">
              <button className="btn btn-link c-secondary px-0" type="button" onClick={() => openShowAutomaticAnswerModal(message)}>
                Ver horarios
              </button>
            </div>
            <div className="col-xl-2 col-md-2 text-left">
              {message.message_type == 'new_customer' && <span>Usuarios nuevos</span>}
              {message.message_type == 'inactive_customer' && <span>Usuarios recurrentes</span>}
              {message.message_type == 'all_customer' && <span>Usuarios nuevos/recurrentes</span>}
            </div>
            <div className="col-xl-2 col-md-2 my-8 pr-100">
              <div className='container-active-channels'>
                { message.whatsapp && <img src={wsIcon} title="whatsapp" /> }
                { message.messenger && <img src={msnIcon} title="Messenger" /> }
                { message.instagram && <img src={igIcon} title="Instagram" /> }
              </div>
            </div>
            <div className="col-xl-2 col-md-4 my-8 text-left">
              <div className="d-flex justify-content-center d-md-block">
                <div className="cursor-pointer d-inline-block fz-14" onClick={() => openEditAutomaticAnswerModal(message)}>
                  <img src={EditIcon} className="edit-icon" title="Editar" />
                  <div className="ml-8 d-inline-block">
                    Editar
                  </div>
                </div>
                <div className="ml-30 cursor-pointer fz-14 d-inline-block" onClick={() => removeAutomaticAnswer(message)}>
                  <i className="fas fa-trash" />
                  <div className="ml-8 d-inline-block">
                    Eliminar
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    ))) : (
      <div className="d-flex align-items-center justify-content-center" style={{ height: '50vh' }}>
        {noMessagesMsg}
      </div>
    )}
  </>
  )
};

export default AutomaticAnswerList;