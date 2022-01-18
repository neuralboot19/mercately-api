/* eslint-disable react/jsx-props-no-spreading */
import React from "react";
import { connect } from "react-redux";
/* eslint-disable-next-line import/no-unresolved */
import Loader from "images/dashboard/loader.jpg";
import { withRouter } from "react-router-dom";
import { DragDropContext, Droppable } from 'react-beautiful-dnd';
import styled from 'styled-components';
import ColumnInnerList from "./ColumnInnerList";
import EditIcon from 'images/edit.svg';

import {
  fetchFunnelSteps,
  clearFunnels,
  updateFunnelStepDeal,
  updateFunnelStep,
  loadMoreDeals
} from "../../actions/funnels";

import { fetchCurrentRetailerUser } from "../../actions/actions";

const Container = styled.div`
  white-space: nowrap;
  margin-top: 25px;
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
      itemDraggableId: "",
      dealPosition: 0
    };
  }

  static getDerivedStateFromProps(props, state) {
    if (!_.isEqual(props.funnelSteps, state.funnelSteps)) {
      props.clearFunnels();
    }
    return null;
  }

  componentDidMount() {
    this.props.fetchFunnelSteps();
    this.props.fetchCurrentRetailerUser();
  }

  componentDidUpdate(prevState) {
    // Optimistic update for list order
    const isEqualDealsAmount = prevState.funnelSteps.deals && !this.props.fetchingFunnels
      && Object.keys(prevState.funnelSteps.deals).length === Object.keys(this.state.funnelSteps.deals).length;
    if (!_.isEqual(prevState.funnelSteps.columnOrder, this.state.funnelSteps.columnOrder)
        && isEqualDealsAmount) {
      this.props.updateFunnelStep({
        columns: this.state.funnelSteps.columnOrder
      });
    }
    // Optimictic update for list item
    if (this.state.itemDroppableId && this.state.itemDraggableId
      && !_.isEqual(prevState.funnelSteps.columns, this.state.funnelSteps.columns)
      && isEqualDealsAmount) {
      this.props.updateFunnelStepDeal({
        funnel_step_id: this.state.itemDroppableId,
        deal_id: this.state.itemDraggableId,
        position: this.state.dealPosition
      });
      this.setState(
        () => ({
          itemDroppableId: null,
          itemDraggableId: null
        })
      );
    }

    if (this.props.fetchingFunnels && !_.isEqual(prevState.funnelSteps, this.props.funnelSteps)) {
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
        itemDroppableId: destination.droppableId,
        itemDraggableId: draggableId,
        dealPosition: destination.index,
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
      dealPosition: destination.index,
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
      <div className="row">
        <div className="col-12">
          <div className="overflow-x-scroll scrollbar-thin">
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
                        className="column-container bg-transparent"
                      >
                        {this.state.funnelSteps.columnOrder && this.state.funnelSteps.columnOrder.map((columnId, index) => {
                          const column = this.state.funnelSteps.columns[columnId];
                          return (
                            <ColumnInnerList
                              key={column.id}
                              column={column}
                              index={index}
                              dealMap={this.props.funnelSteps.deals}
                              openCreateDeal={this.props.openCreateDeal}
                              toggleEditDeal={this.props.toggleEditDeal}
                              deleteStep={this.props.deleteStep}
                              deleteDeal={this.props.deleteDeal}
                              loadMoreDeals={this.props.loadMoreDeals}
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
          </div>
        </div>
      </div>
    );
  }
}

function mapStateToProps({  mainReducer: state }) {
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
    fetchCurrentRetailerUser: () => {
      dispatch(fetchCurrentRetailerUser());
    },
    clearFunnels: () => {
      dispatch(clearFunnels());
    },
    updateFunnelStepDeal: (body) => {
      dispatch(updateFunnelStepDeal(body));
    },
    updateFunnelStep: (body) => {
      dispatch(updateFunnelStep(body));
    },
    loadMoreDeals: (column, page = 1, offset) => {
      dispatch(loadMoreDeals(column, page, offset));
    }
  };
}

export default connect(mapStateToProps, mapDispatch)(withRouter(Funnel));
