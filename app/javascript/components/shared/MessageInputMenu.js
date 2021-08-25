import React from 'react';
import SendLocation from '../icons/SendLocation';
import ShowProduct from '../icons/ShowProduct';

const MessageInputMenu = ({
  handleShowInputMenu,
  getLocation,
  openProducts
}) => (
  <>
    <div className="text-input-btn-plus px-24 py-32 d-flex flex-column justify-content-between align-items-strech">
      <div onClick={getLocation} className="cursor-pointer">
        <SendLocation className="fill-dark" />
        <span className="fs-14 ml-10">Enviar Ubicación</span>
      </div>
      <div onClick={openProducts} className="cursor-pointer">
        <ShowProduct className="fill-dark" />
        <span className="fs-14 ml-10">Ver productos</span>
      </div>
    </div>
    <div onClick={handleShowInputMenu} className="bg-full-screen-fixed"></div>
  </>
);

export default MessageInputMenu;
