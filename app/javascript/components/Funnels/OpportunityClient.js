/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import styled from 'styled-components';
import { Draggable } from 'react-beautiful-dnd';
/* eslint-disable-next-line import/no-unresolved */
import WhatsApp from 'images/dashboard/funnel/whatsapp.png';
import Messenger from 'images/dashboard/funnel/messenger.png';

const Container = styled.div`
  margin-bottom: 8px;
  background-color: ${(props) => (props.isDragging ? '#ebf9ff' : 'white')};
  border: 1px solid grey;
  border-radius: 5px;
  padding: 15px 10px;
  display: flex;
  justify-content: space-between;
  align-items: flex-center;
  .text-danger {
    color: tomato;
  }`;

const OpportunityClient = ({
  deal,
  index,
  openDeleteDeal,
  columnId
}) => (
  <Draggable draggableId={deal.id} index={index}>
    {(provided, snapshot) => (
      <Container
        {...provided.draggableProps}
        {...provided.dragHandleProps}
        ref={provided.innerRef}
        isDragging={snapshot.isDragging}
      >
        <div class="w-100">
          <div class="w-100">
            <p className="funnel-content-name">{deal.name}
              <i
                className="fas fa-trash-alt text-danger f-right"
                onClick={() => openDeleteDeal(deal.id, columnId)}
              ></i>
            </p>

          </div>
          <div>
            {deal.has_whastapp
              && (
              <a href={`/retailers/${ENV.SLUG}/whatsapp_chats?cid=${deal.customer.id}`} className="tooltip-top p-4">
                <img src={WhatsApp} className="funnel-client-whatsapp" />
                <div className="tooltiptext bottom-100">Ver Chat</div>
              </a>
            )}
            {deal.has_fb
              && (
              <a href={`/retailers/${ENV.SLUG}/facebook_chats?cid=${deal.customer.id}`} className="tooltip-top">
                <img src={Messenger} className="funnel-client-whatsapp" />
                <div className="tooltiptext bottom-100">Ver Chat</div>
              </a>
            )}
          </div>
        </div>
      </Container>
    )}
  </Draggable>
);

export default OpportunityClient;
