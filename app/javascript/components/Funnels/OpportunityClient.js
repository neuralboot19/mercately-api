/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import styled from 'styled-components';
import { Draggable } from 'react-beautiful-dnd';
/* eslint-disable-next-line import/no-unresolved */
import WhatsApp from 'images/dashboard/funnel/whatsapp.png';

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
}) => {
  let hasWhatsapp = false;
  if (deal.amount) {
    hasWhatsapp = true;
  }

  return (
    <Draggable draggableId={deal.id} index={index}>
      {(provided, snapshot) => (
        <Container
          {...provided.draggableProps}
          {...provided.dragHandleProps}
          ref={provided.innerRef}
          isDragging={snapshot.isDragging}
        >
          <p className="funnel-content-name">{deal.name}</p>
          <i
            className="fas fa-trash-alt text-danger"
            onClick={() => openDeleteDeal(deal.id, columnId)}
          >
          </i>

          {hasWhatsapp
            && (
            <div className="tooltip-top">
              <img src={WhatsApp} className="funnel-client-whatsapp" />
              <div className="tooltiptext bottom-100">Ver Chat</div>
            </div>
            )}
        </Container>
      )}
    </Draggable>
  );
};

export default OpportunityClient;
