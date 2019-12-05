import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { fetchMessages, sendMessage } from "../../actions/actions";

import MessageForm from './MessageForm';

var currentCustomer = 0;
const csrfToken = document.querySelector('[name=csrf-token]').content

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
    this.setState({ page: this.state.page += 1,  load_more: true})
  }

  componentWillReceiveProps(newProps){
    
    console.log(newProps.messages, this.props.messages)

    if(newProps.messages != this.props.messages){
        
        console.log('')

      // this.setState({
      //   ...this.state,
      //   messages: newProps.messages.concat(this.state.messages)
      // })
    }

  }

  handleSubmitMessage = (e, message) => {
    e.preventDefault();
    let text = { message: message }
    this.props.sendMessage(this.props.currentCustomer, text, csrfToken);
  }

  componentDidUpdate() {

    console.log('UPDATING ARRAY')

    let id = this.props.currentCustomer;
    if (currentCustomer !== id) {
      currentCustomer = id

      // this.setState({ messages: [],  page: 1}, () => {
      //   this.props.fetchMessages(id);
      // });

      App.cable.subscriptions.create(
        { channel: 'FacebookMessagesChannel', id: currentCustomer },
        {
          received: data => {
            // TODO: Build new message instead fetch all messages again
            // this.props.fetchMessages(id);

            this.setState({
              messages: this.state.messages.push('hola')
            })
          }
        }
      );
    } else if (this.state.load_more === true) {
      this.setState({ load_more: false }, () => {
        this.props.fetchMessages(id, this.state.page);
      });
    }
  }

  render() {
    console.log('state', this.state)
    return (
      <div className="row bottom-xs">
        <div className="col-xs-12 chat__box">
          <a href="" onClick={(e) => this.handleLoadMore(e)}>Load more</a>
          {this.state.messages.map((message) => {
            return(
              <div key={message.id} className={'message' + message.sent_by_retailer == true ? 'message-by-retailer f-right' : ''}>
                {message.text}
              </div>
            ) 
          })}
        </div>
        <div className="col-xs-12">
          <MessageForm
            currentCustomer={this.props.currentCustomer}
            handleSubmitMessage={this.handleSubmitMessage}
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    messages: state.messages || [],
    message: state.message || [],
  };
}

function mapDispatch(dispatch) {
  return {
    fetchMessages: (id, page = 1) => {
      dispatch(fetchMessages(id, page));
    },
    sendMessage: (id, message, token) => {
      dispatch(sendMessage(id, message, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatch
)(withRouter(ChatMessages));
