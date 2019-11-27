import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages } from "../../actions/actions";

class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
    };
  }

  componentDidUpdate() {
    let id = this.props.currentCustomer;
    console.log(id);
    this.props.fetchMessages(id);
  }

  render() {
    return (
      <div>{this.props.currentCustomer}</div>
    )
  }
}


function mapState(state) {
  return {
    customers: state.customers || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id) => {
      dispatch(fetchMessages(id));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatMessages));
