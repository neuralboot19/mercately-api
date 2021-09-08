/* eslint-disable react/jsx-props-no-spreading */
import React, { useState } from "react";
import { Droppable, Draggable } from 'react-beautiful-dnd';
import styled from 'styled-components';
/* eslint-disable-next-line import/no-unresolved */
import ArrowDown from 'images/down_arrow.svg';
import InnerList from "./InnerList";
import ColumnHeader from "./ColumnHeader";

const Container = styled.div`
  border-radius: 2px;
  width: 325px;
  display: inline-block;
  vertical-align: text-top;
  background-color: ${(props) => (props.isDragging ? "#ebf9ff" : "transparent")};
`;

const DealList = styled.div`
  padding: 8px;
  transition: background-color 0.2s ease;
  height: calc(100vh - 400px);
  max-height: calc(100vh - 400px);
  overflow-y: auto;
  background-color: ${(props) => (props.isDraggingOver ? "#D3D3D3" : "transparent")};
`;

const Column = ({
  column,
  index,
  openCreateDeal,
  toggleEditDeal,
  deleteStep,
  deleteDeal,
  deals,
  loadMoreDeals
}) => {
  const [page, setPage] = useState(1);
  const HandleLoadMoreDeals = () => {
    loadMoreDeals(column.id, page, column.dealIds.length);
    setPage(page + 1);
  };
  // if (column.id === '108blwqt9' && column.total > column.dealIds.length && (column.total > 0 || column.dealIds.length > 0)) debugger;

  return (
    <Draggable draggableId={column.id} index={index}>
      {(provided, snapshot) => (
        <Container
          {...provided.draggableProps}
          ref={provided.innerRef}
          isDragging={snapshot.isDragging}
        >
          <ColumnHeader
            provided={provided}
            dealInfo={column}
            openCreateDeal={openCreateDeal}
            deleteStep={deleteStep}
          />
          <Droppable
            droppableId={column.id}
            type="deal"
          >
            {(stepProvided, stepSnapshot) => (
              <DealList
                ref={stepProvided.innerRef}
                {...stepProvided.droppableProps}
                isDraggingOver={stepSnapshot.isDraggingOver}
                isDragging={stepSnapshot.isDragging}
              >
                <InnerList
                  deleteDeal={deleteDeal}
                  deals={deals}
                  toggleEditDeal={toggleEditDeal}
                  columnId={column.id}
                />
                {stepProvided.placeholder}
                {
                  column.total > column.dealIds.length && column.dealIds.length > 0 && (
                    <div className="text-center mt-25">
                      <a
                        className="fz-14 c-primary"
                        onClick={() => HandleLoadMoreDeals(column.id, page)}
                      >
                        Cargar más <img src={ArrowDown} />
                      </a>
                    </div>
                  )
                }
              </DealList>
            )}
          </Droppable>
        </Container>
      )}
    </Draggable>
  );
};

export default Column;
