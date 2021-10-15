import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { getMessengerFastAnswers, getInstagramFastAnswers } from "../../actions/actions";
import { getWhatsAppFastAnswers } from "../../actions/whatsapp_karix";

import SearchIcon from 'images/search.svg';

const csrfToken = document.querySelector('[name=csrf-token]').content

class FastAnswers extends Component {
  constructor(props) {
    super(props)
    this.state = {
      fastAnswers: [],
      searchString: '',
      shouldUpdate: true,
      page: 1
    };
  }

  componentDidMount() {
    switch (this.props.chatType) {
      case 'whatsapp':
        this.props.getWhatsAppFastAnswers();
        break;
      case 'facebook':
        this.props.getMessengerFastAnswers();
        break;
      case 'instagram':
        this.props.getInstagramFastAnswers();
        break
    }
  }

  componentDidUpdate() {
    if (this.state.shouldUpdate) {
      this.setState({
        fastAnswers: this.props.fastAnswers,
        shouldUpdate: false
      })
    }
  }

  componentWillReceiveProps(newProps) {
    if (newProps.fastAnswers != this.props.fastAnswers) {
      this.setState({
        fastAnswers: this.state.fastAnswers.concat(newProps.fastAnswers)
      })
    }
  }

  changeFastAnswer = (answer) => {
    this.props.changeFastAnswer(answer);
  }

  handleChatSearch = (e) => {
    let value;
    value = e.target.value;
    this.setState({
      searchString: value,
    });
  }

  handleKeyPress = event => {
    if (event.key === "Enter") {
      this.setState({shouldUpdate: true}, () => {
        this.applySearch();
      })
    }
  };

  applySearch = () => {
    this.setState({fastAnswers: [], page: 1}, () => {
      switch (this.props.chatType) {
        case 'whatsapp':
          this.props.getWhatsAppFastAnswers(1, this.state.searchString);
          break;
        case 'facebook':
          this.props.getMessengerFastAnswers(1, this.state.searchString);
          break;
        case 'instagram':
          this.props.getInstagramFastAnswers(1, this.state.searchString);
          break;
      }
    })
  }

  toggleFastAnswers = () => {
    this.props.toggleFastAnswers();
  }

  handleLoadMoreOnScrollToBottom = (e) => {
    e.preventDefault();
    e.stopPropagation();
    let el = e.target;
    let style = window.getComputedStyle(el, null);
    let scrollHeight = parseInt(style.getPropertyValue("height"));

    if (el.scrollTop + scrollHeight >= el.scrollHeight - 5) {
      this.handleLoadMore();
    }
  }

  handleLoadMore = () => {
    if (this.props.total_pages > this.state.page) {
      let page = ++this.state.page;
      this.setState({ page: page })

      switch (this.props.chatType) {
        case 'whatsapp':
          this.props.getWhatsAppFastAnswers(page, this.state.searchString);
          break;
        case 'facebook':
          this.props.getMessengerFastAnswers(page, this.state.searchString);
          break;
        case 'instagram':
          this.props.getInstagramFastAnswers(page, this.state.searchString);
          break;
      }
    }
  }

  render() {
    return (
      <div className={this.props.onMobile ? "customer_sidebar chat-right-side-selector no-border-left" : "quickly-answers-container customer_sidebar chat-right-side-selector" } onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
        <div className="customer-box-quickly-answers">
          <span>
            Respuestas Rápidas
            <i className="fs-18 mt-4 mr-4 f-right fas fa-times cursor-pointer" onClick={() => this.toggleFastAnswers()}></i>
          </span>
        </div>
        <div className="customer_details details-mobile-height">
          <div className="p-relative">
            <input
              type="text"
              value={this.state.searchString}
              onChange={(e) => this.handleChatSearch(e) }
              placeholder="Busqueda por título o contenido"
              className="input-icon bg-light search-fast-answer"
              onKeyPress={this.handleKeyPress}
            />
            <span className="p-absolute icon-search">
              <img src={SearchIcon} alt="search icon" />
            </span>
          </div>
          {this.state.fastAnswers.map((answer) => (
            <div key={answer.id} className="fast_answer_content" onClick={() => this.changeFastAnswer(answer)}>
              <div className="container-answer-title">
                <span className="answer-title">{answer.attributes.title}</span>
                <span className="select_answer"><i className="fas fa-check-circle check-icon"></i></span>
              </div>
              <div className="divider"></div>
              <div className="container-answer-description">
                {answer.attributes.image_url && (
                  <div className="image-answer-description">
                    {answer.attributes.file_type === 'image' ? (
                      <img src={answer.attributes.image_url} />
                    ) : (
                      <embed src={answer.attributes.image_url} />
                    )}
                  </div>
                )}
                <small className="text-pre-line text-answer-description">{answer.attributes.answer}</small>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }
}

function mapState(state) {
  return {
    fastAnswers: state.fast_answers || [],
    total_pages: state.total_pages
  };
}

function mapDispatch(dispatch) {
  return {
    getWhatsAppFastAnswers: (page = 1, params) => {
      dispatch(getWhatsAppFastAnswers(page, params));
    },
    getMessengerFastAnswers: (page = 1, params) => {
      dispatch(getMessengerFastAnswers(page, params));
    },
    getInstagramFastAnswers: (page = 1, params) => {
      dispatch(getInstagramFastAnswers(page, params));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(FastAnswers));
