import React, { useEffect, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import AutomaticAnswerFields from './AutomaticAnswerFields';
import { updateAutomaticAnswer } from '../../actions/automaticAnswers';

const EditAutomaticAnswer = ({ automaticAnswer, toggleModal, retailerInfo }) => {
  const automaticAnswerRef = useRef();
  const dispatch = useDispatch();
  const { closeModal } = useSelector((reduxState) => reduxState.automaticAnswersReducer);

  const handleUpdateAutomaticAnswer = (e) => {
    e.preventDefault();
    const el = e.target;
    el.disabled = true;
    if (automaticAnswerRef.current.handleValidation()) {
      dispatch(updateAutomaticAnswer(automaticAnswerRef.current.body.id, automaticAnswerRef.current.body));
    } else {
      el.disabled = false;
    }
  };

  useEffect(() => {
    if (closeModal) {
      toggleModal();
      const data = {toggle: false};
      dispatch({ type: 'TOGGLE_MODAL', data})
    }
  }, [closeModal]);

  return (
    <form onSubmit={handleUpdateAutomaticAnswer}>
      <AutomaticAnswerFields currentAutomaticAnswer={automaticAnswer} ref={automaticAnswerRef} retailerInfo={retailerInfo} />

      <div className="row align-items-center mt-20">
        <div className="col text-center">
          <button type="submit" className="blue-button">Actualizar horario</button>
        </div>
      </div>
    </form>
  );
};

export default EditAutomaticAnswer;
