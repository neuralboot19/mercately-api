import React from 'react';

const BoxMenu = ({
  hideMenu,
  children
}) => (
  <>
    <div className="funnels-box-menu px-8 py-24 d-flex flex-column justify-content-between align-items-strech cursor fs-14">
      {children}
    </div>
    <div className="bg-full-screen-fixed cursor" onClick={hideMenu}></div>
  </>
);

export default BoxMenu;
