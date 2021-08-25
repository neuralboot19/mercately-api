import React from 'react';
// eslint-disable-next-line import/no-unresolved
import FastIcon from 'images/fast.svg';

const FastAnswerButton = ({ toggleFastAnswers }) => (  
  <div className="d-inline-block">
    <div onClick={() => toggleFastAnswers()} className="rounded-pill border border-gray ml-24 cursor-pointer fs-12 p-10 mb-16">
      <img className="mr-4" src={FastIcon} alt="fast answers icon" />
      <span>Respuestas rápidas</span>
    </div>
  </div>
)

export default FastAnswerButton;
