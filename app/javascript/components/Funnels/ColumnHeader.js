import React, { useState } from "react";
/* eslint-disable react/jsx-props-no-spreading */
/* eslint-disable-next-line import/no-unresolved */
import OpenFunnelOptionsIcon from 'images/new_design/open-funnel-options.svg';
import PlusIcon from '../icons/PlusIcon';
import TrashIcon from '../icons/TrashIcon';
import BoxMenu from './BoxMenu';
import FunnelOutlineIcon from '../icons/FunnelOutlineIcon';
import DollarSignOutlineIcon from "../icons/DollarSignOutlineIcon";

const ColumnHeader = ({
  provided,
  dealInfo,
  openCreateDeal,
  deleteStep
}) => {
  const [showMenu, setShowMenu] = useState(false);

  const handleOpenCreate = () => {
    openCreateDeal(
      dealInfo.internal_id,
      dealInfo.id,
      dealInfo.r_internal_id
    );
    setShowMenu(false);
  };

  const handleOpenDelete = () => {
    deleteStep(dealInfo.id);
    setShowMenu(false);
  };

  return (
    <div className="column-header mx-8 my-16 p-16 bg-white border-16 position-relative" {...provided.dragHandleProps}>
      <div className="column-title">
        <h1 className="mt-0 mb-8">{dealInfo.title}</h1>
        <div className="column-title-content">
          <p className="d-flex align-items-center mb-8">
            <FunnelOutlineIcon className="column-title-icon mr-5" />
            {dealInfo.deals}
            {" "}
            {dealInfo.deals === 1 ? "negociación" : "negociaciones"}
          </p>
          <p className="d-flex align-items-center">
            {dealInfo.currency}
            {dealInfo.amount}
          </p>
        </div>

        {showMenu && (
          <BoxMenu
            hideMenu={() => setShowMenu(false)}
          >
            <div className="cursor-pointer mb-4 px-18 py-8 border-8" onClick={handleOpenCreate}>
              <PlusIcon />
              <span className="fs-14 ml-10">Agregar negociación</span>
            </div>
            <div className="cursor-pointer px-18 py-8 border-8" onClick={handleOpenDelete}>
              <TrashIcon />
              <span className="fs-14 ml-10">Eliminar etapa</span>
            </div>
          </BoxMenu>
        )}
        <img
          className="funnel-box-menu-img cursor-pointer"
          src={OpenFunnelOptionsIcon}
          alt="Open Funnel Options Icon"
          onClick={() => setShowMenu(true)}
        />
      </div>
    </div>
  );
};

export default ColumnHeader;
