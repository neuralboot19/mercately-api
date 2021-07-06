/* eslint-disable react/jsx-props-no-spreading */
import React, { useState } from "react";
import styled from "styled-components";
import { Droppable, Draggable } from "react-beautiful-dnd";
import InnerList from "./InnerList";
import ColumnHeader from "./ColumnHeader";

const Container = styled.div`
  border-radius: 2px;
  width: 325px;
  display: inline-block;
  vertical-align: text-top;
  background-color: ${(props) => (props.isDragging ? "#ebf9ff" : "white")};
`;

const DealList = styled.div`
  padding: 8px;
  transition: background-color 0.2s ease;
  min-height: 80vh;
  border-right: 1px solid #eeeeee;
  background-color: ${(props) => (props.isDraggingOver ? "#D3D3D3" : "#F8F8F8")};
`;

const Column = ({
  column,
  index,
  openCreateDeal,
  openDeleteStep,
  openDeleteDeal,
  allowColumn,
  deals,
  loadMoreDeals
}) => {

  const [page, setPage] = useState(2)

  const HandleLoadMoreDeals = () => {
    loadMoreDeals(column.id, page);
    setPage(page + 1);
  }

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
            openDeleteStep={openDeleteStep}
          />
          <Droppable
            droppableId={column.id}
            isDropDisabled={allowColumn === column.id}
            type="deal"
          >
            {(provided, snapshot) => (
              <DealList
                ref={provided.innerRef}
                {...provided.droppableProps}
                isDraggingOver={snapshot.isDraggingOver}
                isDragging={snapshot.isDragging}
              >
                <InnerList  
                  openDeleteDeal={openDeleteDeal}
                  deals={deals}
                  columnId={column.id}
                />
                {provided.placeholder}
              </DealList>
            )}
          </Droppable>
          {
            column.total > column.dealIds.length &&
              <h1
                className="py-5 px-15 funnel-btn btn--cta m-10"
                onClick={()=>HandleLoadMoreDeals(column.id, page)}
              >
                <p style={{textAlign: 'center'}}>Ver Mas de la etapa: <b>{column.title}</b></p>
              </h1>
          }
        </Container>
      )}
    </Draggable>
  );
}

export default Column;
