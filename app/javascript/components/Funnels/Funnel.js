/* eslint-disable react/jsx-props-no-spreading */
import React from "react";
import { connect } from "react-redux";
import Loader from "images/dashboard/loader.jpg";
import { withRouter } from "react-router-dom";
import { DragDropContext, Droppable } from "react-beautiful-dnd";
import styled from "styled-components";
import ColumnInnerList from "./ColumnInnerList";

import {
  fetchFunnelSteps,
  clearFunnels,
  updateFunnelStepDeal,
  updateFunnelStep
} from "../../actions/funnels";

const Container = styled.div`
  white-space: nowrap;
  height: 70vh;
  margin-top: 25px;
  border-left: 1px solid #eeeeee;
  border-right: 1px solid #eeeeee;
  display: inline-flex;
  background-color: ${(props) => (props.isDragging ? "lightgreen" : "white")};
`;

class Funnel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      funnelSteps: {},
      loadedData: false,
      newStep: {},
      columnWebId: "",
      currentDragColumnId: "",
      itemDroppableId: "",
      itemDraggableId: ""
    };
  }

  static getDerivedStateFromProps(props, state) {
    if (props.funnelSteps !== state.funnelSteps) {
      props.clearFunnels();
    }
    return null;
  }

  componentDidMount() {
    this.props.fetchFunnelSteps();
  }

  componentDidUpdate(prevState) {
    // Optimistic update for list order
    if (prevState.funnelSteps.columnOrder !== this.state.funnelSteps.columnOrder) {
      this.props.updateFunnelStep({
        columns: this.state.funnelSteps.columnOrder
      });
    }
    // Optimictic update for list item
    if (prevState.funnelSteps.columns !== this.state.funnelSteps.columns) {
      this.props.updateFunnelStepDeal({
        funnel_step_id: this.state.itemDroppableId,
        deal_id: this.state.itemDraggableId
      });
    }

    if (this.props.fetchingFunnels) {
      this.setState(
        () => ({
          loadedData: true,
          funnelSteps: this.props.funnelSteps
        })
      );
    }
  }

  onDragStart = (start) => {
    if (start.type === "deal") {
      this.setState({
        currentDragColumnId: start.source.droppableId
      });
    }
  };

  onDragEnd = (result) => {
    const {
      destination, source, draggableId, type
    } = result;

    if (!destination) {
      return;
    }

    if (
      destination.droppableId === source.droppableId
      && destination.index === source.index
    ) {
      return;
    }

    if (type === "column") {
      const newColumnOrder = Array.from(this.state.funnelSteps.columnOrder);
      newColumnOrder.splice(source.index, 1);
      newColumnOrder.splice(destination.index, 0, draggableId);
      const newState = {
        ...this.state,
        funnelSteps: {
          ...this.state.funnelSteps,
          columnOrder: newColumnOrder
        }
      };

      // Optimistic update for list order
      this.setState(newState);
      return;
    }

    const home = this.state.funnelSteps.columns[source.droppableId];
    const foreign = this.state.funnelSteps.columns[destination.droppableId];

    if (home === foreign) {
      const newDealIds = Array.from(home.dealIds);
      newDealIds.splice(source.index, 1);
      newDealIds.splice(destination.index, 0, draggableId);

      const newHome = {
        ...home,
        dealIds: newDealIds
      };

      const newState = {
        ...this.state,
        funnelSteps: {
          ...this.state.funnelSteps,
          columns: {
            ...this.state.funnelSteps.columns,
            [newHome.id]: newHome
          }
        }
      };

      this.setState(newState);
      return;
    }

    // moving from one list to another
    const homeDealIds = Array.from(home.dealIds);
    const homeDealNumber = home.deals;

    homeDealIds.splice(source.index, 1);
    const newHome = {
      ...home,
      dealIds: homeDealIds,
      deals: homeDealNumber - 1
    };

    const foreignDealIds = Array.from(foreign.dealIds);
    const foreignDealnumber = foreign.deals;

    foreignDealIds.splice(destination.index, 0, draggableId);
    const newForeign = {
      ...foreign,
      dealIds: foreignDealIds,
      deals: foreignDealnumber + 1
    };

    const newState = {
      ...this.state,
      itemDroppableId: destination.droppableId,
      itemDraggableId: draggableId,
      funnelSteps: {
        ...this.state.funnelSteps,
        columns: {
          ...this.state.funnelSteps.columns,
          [newHome.id]: newHome,
          [newForeign.id]: newForeign
        }
      }
    };

    // Optimictic update for list item
    this.setState(newState);
  };

  render() {
    return (
      <div className="funnel_holder">
        {this.state.loadedData ? (
          <DragDropContext
            onDragEnd={this.onDragEnd}
            onDragStart={this.onDragStart}
          >
            <Droppable
              droppableId="all-columns"
              direction="horizontal"
              type="column"
            >
              {(provided) => (
                <Container
                  {...provided.droppableProps}
                  ref={provided.innerRef}
                  className="column-container"
                >
                  {this.state.funnelSteps.columnOrder.map((columnId, index) => {
                    const column = this.state.funnelSteps.columns[columnId];
                    return (
                      <ColumnInnerList
                        key={column.id}
                        column={column}
                        index={index}
                        dealMap={this.state.funnelSteps.deals}
                        openCreateDeal={this.props.openCreateDeal}
                        openDeleteStep={this.props.openDeleteStep}
                        allowColumn={this.state.currentDragColumnId}
                      />
                    );
                  })}
                  {provided.placeholder}
                </Container>
              )}
            </Droppable>
          </DragDropContext>
        ) : (
          <div className="chat_loader">
            <img src={Loader} />
          </div>
        )}
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    funnelSteps: state.funnelSteps || {},
    fetchingFunnels: state.fetching_funnels || false
  };
}

function mapDispatch(dispatch) {
  return {
    fetchFunnelSteps: () => {
      dispatch(fetchFunnelSteps());
    },
    clearFunnels: () => {
      dispatch(clearFunnels());
    },
    updateFunnelStepDeal: (body) => {
      dispatch(updateFunnelStepDeal(body));
    },
    updateFunnelStep: (body) => {
      dispatch(updateFunnelStep(body));
    }
  };
}

export default connect(mapStateToProps, mapDispatch)(withRouter(Funnel));
