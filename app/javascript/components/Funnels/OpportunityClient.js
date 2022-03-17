/* eslint-disable react/jsx-props-no-spreading */
import React, { useState } from 'react';
import styled from 'styled-components';
import numeral from 'numeral';
import ReactTooltip from 'react-tooltip';
import { Draggable } from 'react-beautiful-dnd';
/* eslint-disable-next-line import/no-unresolved */
import WhatsApp from 'images/dashboard/funnel/whatsapp.png';
/* eslint-disable-next-line import/no-unresolved */
import Messenger from 'images/dashboard/funnel/messenger.png';
/* eslint-disable-next-line import/no-unresolved */
import Instagram from 'images/dashboard/funnel/instagram.png';
/* eslint-disable-next-line import/no-unresolved */
import OpenFunnelOptionsIcon from 'images/new_design/open-funnel-options.svg';
/* eslint-disable-next-line import/no-unresolved */
import EditIcon from 'images/edit.svg';
import TrashIcon from '../icons/TrashIcon';
import BoxMenu from './BoxMenu';

const Container = styled.div`
  margin-bottom: 24px;
  background-color: ${(props) => (props.isDragging ? '#ebf9ff' : 'white')};
  border-radius: 16px;
  padding: 16px;
  display: flex;
  position: relative;
  justify-content: space-between;
  align-items: flex-center;
  .text-danger {
    color: tomato;
  }`;

const OpportunityClient = ({
  deal,
  index,
  deleteDeal,
  toggleEditDeal,
  columnId
}) => {
  const [showMenu, setShowMenu] = useState(false);
  const handleOpenDelete = () => {
    deleteDeal(deal.id, columnId);
    setShowMenu(false);
  };

  const handleOpenEdit = () => {
    toggleEditDeal(
      deal,
      columnId
    );
    setShowMenu(false);
  };

  return (
    <Draggable draggableId={deal.id} index={index}>
      {(provided, snapshot) => (
        <Container
          {...provided.draggableProps}
          {...provided.dragHandleProps}
          ref={provided.innerRef}
          isDragging={snapshot.isDragging}
        >
          <div className="w-100">
            <ReactTooltip effect="solid" />
            <div className="w-100">
              <p
                className={`funnel-content-name text-truncate ${!(deal.amount && deal.customer && deal.agent) && 'my-8'}`}
                style={{ width: 'calc(100% - 35px)' }}
              >
                {deal.name}
                {deal.customer && (
                  <div className="text-secondary fz-11 font-weight-light">
                    {`${deal.customer.first_name || ''} ${deal.customer.last_name || ''}`}
                  </div>
                )}
              </p>
              {showMenu && (
                <BoxMenu
                  hideMenu={() => setShowMenu(false)}
                >
                  <div
                    className="cursor-pointer px-18 py-8 border-8"
                    onClick={handleOpenEdit}
                  >
                    <img src={EditIcon} width="12" height="14" />
                    <span className="fs-14 ml-10">Editar negociación</span>
                  </div>
                  <div
                    className="cursor-pointer px-18 py-8 border-8"
                    onClick={handleOpenDelete}
                  >
                    <TrashIcon />
                    <span className="fs-14 ml-10">Eliminar negociación</span>
                  </div>
                </BoxMenu>
              )}
            </div>
            <div>
              {deal.agent && (
                <p
                  className="d-inline-block funnel-agent mr-6 mb-0"
                  data-tip={`Agente: ${deal.agent.first_name || ''} ${deal.agent.last_name || ''}`}
                >
                  {deal.agent.first_name?.charAt(0)?.toUpperCase() + (deal.agent.last_name?.charAt(0)?.toUpperCase() || '')}
                </p>
              )}
              {deal.customer && (
                <div className="d-inline-block">
                  {deal.channel === 'whatsapp'
                      && (
                        <a
                          href={`/retailers/${ENV.SLUG}/whatsapp_chats?cid=${deal.customer.id}`}
                          data-tip="Ver chat"
                          target="_blank"
                        >
                          <img src={WhatsApp} className="funnel-client-whatsapp" />
                        </a>
                      )}
                  {deal.channel === 'messenger'
                      && (
                        <a
                          href={`/retailers/${ENV.SLUG}/facebook_chats?cid=${deal.customer.id}`}
                          data-tip="Ver chat"
                          target="_blank"
                        >
                          <img src={Messenger} className="funnel-client-whatsapp" />
                        </a>
                      )}
                  {deal.channel === 'instagram'
                      && (
                        <a
                          href={`/retailers/${ENV.SLUG}/instagram_chats?cid=${deal.customer.id}`}
                          data-tip="Ver chat"
                          target="_blank"
                        >
                          <img src={Instagram} className="funnel-client-whatsapp" />
                        </a>
                      )}
                </div>
              )}
            </div>
            {deal.amount && (
              <div className="mt-8">
                <p className="m-0 funnel-deal-amount">
                  {deal.currency}
                  {numeral(deal.amount).format('0.00')}
                </p>
              </div>
            )}
            <img
              className="funnel-box-menu-img cursor-pointer"
              src={OpenFunnelOptionsIcon}
              alt="Open Funnel Options Icon"
              onClick={() => setShowMenu(true)}
            />
          </div>
        </Container>
      )}
    </Draggable>
  );
};

export default OpportunityClient;
