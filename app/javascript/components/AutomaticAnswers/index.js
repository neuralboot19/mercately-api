import React, { useEffect, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import ReactPaginate from 'react-paginate';

import ModalWindow from '../shared/ModalWindow'
import AutomaticAnswerList from './AutomaticAnsweresList';
import CreateAutomaticAnswer from './CreateAutomaticAnswer';
import EditAutomaticAnswer from './EditAutomaticAnswer';
import ShowAutomaticAnswer from './ShowAutomaticAnswer';

import { getAutomaticAnswers } from '../../actions/automaticAnswers';
import { getRetailerInfo } from '../../actions/retailerUsersActions'
import Advice from '../shared/Advice';

const AutomaticAnswers = () => {
  const dispatch = useDispatch();
  const { messages, total_pages } = useSelector((reduxState) => reduxState.automaticAnswersReducer);
  const { retailer_info } = useSelector((reduxState) => reduxState.retailerUsersReducer);

  const [page, setPage] = useState(1);

  const [automaticAnswer, setAutomaticAnswer] = useState({});

  const noMessagesMsg = 'Sin mensajes de bienvenida.';
  const adviceLink = `Debes establecer tu zona horaria <a href="/retailers/${ENV.SLUG}/edit">aquí</a>. Para que tus mensajes se configuren en el horario correcto.`

  const createAutomaticAnswerModalRef = useRef();
  const editAutomaticAnswerModalRef = useRef();
  const showAutomaticAnswerModalRef = useRef();
  const toggleCreateModal = () => createAutomaticAnswerModalRef.current.toggleModal();
  const toggleEditModal = () => editAutomaticAnswerModalRef.current.toggleModal();
  const toggleShowModal = () => showAutomaticAnswerModalRef.current.toggleModal();
  const modal_sm = {width: '40%'};

  useEffect(() => {
    dispatch(getRetailerInfo());
  }, []);

  useEffect(() => {
    dispatch(getAutomaticAnswers(page));
  }, [page]);

  const openEditAutomaticAnswerModal = (messageSelected) => {
    setAutomaticAnswer(messageSelected);
    toggleEditModal();
  };

  const openShowAutomaticAnswerModal = (messageSelected) => {
    setAutomaticAnswer(messageSelected);
    toggleShowModal();
  }

  const handlePageClick = (e) => {
    setPage(e.selected + 1);
  };

  return(
    <div className="content_width ml-sm-108 mt-25 px-15 no-left-margin-xs">
      <ModalWindow title="Mensaje de bienvenida" customStyle={modal_sm} ref={showAutomaticAnswerModalRef}>
        <ShowAutomaticAnswer currentAutomaticAnswer={automaticAnswer} toggleModal={toggleShowModal} />
      </ModalWindow>
      <ModalWindow title="Añadir mensaje de bienvenida" customStyle={modal_sm} ref={createAutomaticAnswerModalRef}>
        <CreateAutomaticAnswer toggleModal={toggleCreateModal} retailerInfo={retailer_info} />
      </ModalWindow>
      <ModalWindow title="Editar mensaje de bienvenida" customStyle={modal_sm} ref={editAutomaticAnswerModalRef}>
        <EditAutomaticAnswer 
          automaticAnswer={automaticAnswer}
          toggleModal={toggleEditModal}
          retailerInfo={retailer_info}
        />
      </ModalWindow>
      { !ENV.CURRENT_RETAILER_TIMEZONE && (<Advice html={adviceLink} />)}
      <div className="container-fluid-no-padding">
        <div className="row">
          <div className="col-12 col-sm-12">            
            <div className="col justify-content-between d-flex px-0">
              <h1 className="page__title">Mensajes de bienvenida</h1>
              <a className="blue-button my-md-0" onClick={toggleCreateModal}>+ Añadir mensaje de bienvenida</a>
            </div>
            <div className="col-sm-12 no-padding px-0">
              <ol className="breadcrumb pl-0 pb-0 mb-0 bg-transparent">
                <li className="breadcrumb-item">
                  <a className="no-style" href={`/retailers/${ENV['SLUG']}/dashboard`}>
                    Dashboard
                  </a>
                </li>
                <li className="breadcrumb-item active">
                  <a className="no-style" href="#">
                    Mensajes de bienvenida
                  </a>
                </li>
              </ol>
            </div>
          </div>
        </div>

        <div className='row box-container mt-24 br-16'>
          <div className="table box">
            <div className="row">
              <div className="col">
                <div className="ml-0 no-border shadow-none p-0">
                  <ul className="list-group list-group-flush d-none d-md-block bg-transparent">
                    <li className="list-group-item text-secondary pt-54 pb-22 px-0 bg-transparent">
                      <div className="fz-14 text-center row hide-on-tablet-and-down center-sm">
                        <div className="col-4 text-left pl-56">Mensaje</div>
                        <div className="col-2 text-left">Horario</div>
                        <div className="col-2 text-left">Tipo de usuario</div>
                        <div className="col-2 text-left">Canales</div>
                        <div className="col-2 text-left">Acciones</div>
                      </div>
                    </li>
                  </ul>
                  <div className="table-body">
                    <AutomaticAnswerList 
                      messages={messages}
                      noMessagesMsg={noMessagesMsg}
                      openEditAutomaticAnswerModal={openEditAutomaticAnswerModal}
                      openShowAutomaticAnswerModal={openShowAutomaticAnswerModal} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="row col-md-12 mt-30 d-flex justify-content-center">
          <div className="stats-pagination">
            {total_pages > 1 && (
              <ReactPaginate
                nextLabel="Siguiente >"
                onPageChange={handlePageClick}
                pageRangeDisplayed={5}
                marginPagesDisplayed={2}
                pageCount={total_pages}
                previousLabel="< Anterior"
                pageClassName="page-item"
                pageLinkClassName="page-link"
                previousClassName="page-item"
                previousLinkClassName="page-link"
                nextClassName="page-item"
                nextLinkClassName="page-link"
                breakLabel="..."
                breakClassName="page-item"
                breakLinkClassName="page-link"
                containerClassName="pagination"
                activeClassName="active"
                renderOnZeroPageCount={null} />
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default AutomaticAnswers
