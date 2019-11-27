import React, { Component } from 'react';
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchCustomers } from "../../actions/actions";

import ChatListUser from './ChatListUser';

class ChatList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      customers: []
    };
  }

  componentDidMount() {
    this.props.fetchCustomers();
  }

  render() {
    return (
      <div className="chat__selector">
        {this.props.customers.map((customer) => <ChatListUser key={customer.psid} customer={customer}/>)}
      </div>
    );
  }
}

function mapState(state) {
  return {
    customers: state.customers || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchCustomers: () => {
      dispatch(fetchCustomers());
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(ChatList));

