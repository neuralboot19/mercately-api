import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages } from "../../actions/actions";

import ChatMessage from './ChatMessage';

var currentCustomer = 0;
class ChatMessages extends Component {
  constructor(props) {
    super(props)
    this.state = {
      load_more: false,
      page: 1,
      messages: []
    };
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.setState({
      ...this.state,
      page: this.state.page += 1,
      load_more: true
    })
  }

  componentWillReceiveProps(newProps){
    if(newProps.messages != this.props.messages){
      this.setState({
        ...this.state,
        messages: newProps.messages.concat(this.state.messages)
      })
    }
  }

  componentDidUpdate() {
    let id = this.props.currentCustomer;
    if (currentCustomer !== id) {
      currentCustomer = id
      this.props.fetchMessages(id);
      App.cable.subscriptions.create(
        { channel: 'FacebookMessagesChannel', id: currentCustomer },
        {
          received: data => {
            // TODO: Build new message instead fetch all messages again
            console.log(data);
            this.props.fetchMessages(id);
          }
        }
      );
    } else if (this.state.load_more === true) {
      this.setState({
        ...this.state,
        load_more: false
      });
      this.props.fetchMessages(id, this.state.page);
    }
  }

  render() {
    return (
      <div className="row bottom-xs">
        <div className="col-xs-12 chat__box">
          {this.state.messages.map((message) => (
          <ChatMessage key={message.id} message={message}/>
          ))}
          <a href="" onClick={(e) => this.handleLoadMore(e)}>Load more</a>
        </div>
      </div>
    )
  }
}


function mapStateToProps(state) {
  return {
    messages: state.messages || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id, page = 1) => {
      dispatch(fetchMessages(id, page));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
