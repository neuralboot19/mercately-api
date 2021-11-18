import React from 'react';
import FastIcon from 'images/new_design/deal.svg';

const DealButton = ({ openDealModal }) => (
  <div className="d-inline-block">
    <div onClick={() => openDealModal()} className="rounded-pill border border-gray ml-12 cursor-pointer fs-12 p-10 mb-16">
      <img className="mr-4" src={FastIcon} alt="fast answers icon" />
      <span>Crear negociación</span>
    </div>
  </div>
)

export default DealButton;