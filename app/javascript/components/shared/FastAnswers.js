import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { getMessengerFastAnswers } from "../../actions/actions";
import { getWhatsAppFastAnswers } from "../../actions/whatsapp_karix";

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
    if (this.props.chatType == 'facebook') {
      this.props.getMessengerFastAnswers();
    }

    if (this.props.chatType == 'whatsapp') {
      this.props.getWhatsAppFastAnswers();
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
      if (this.props.chatType == 'whatsapp'){
        this.props.getWhatsAppFastAnswers(1, this.state.searchString);
      }
      if (this.props.chatType == 'facebook'){
        this.props.getMessengerFastAnswers(1, this.state.searchString);
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

      if (this.props.chatType == "facebook"){
        this.props.getMessengerFastAnswers(page, this.state.searchString);
      }
      if (this.props.chatType == "whatsapp"){
        this.props.getWhatsAppFastAnswers(page, this.state.searchString);
      }
    }
  }

  render() {
    return (
      <div className={this.props.onMobile ? "customer_sidebar chat-right-side-selector no-border-left" : "customer_sidebar chat-right-side-selector" } onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
        <div className="customer_box">
          <p>
            Respuestas Rápidas
            <i className="fs-18 mt-4 mr-4 f-right fas fa-times cursor-pointer" onClick={() => this.toggleFastAnswers()}></i>
          </p>
        </div>
        <div className="customer_details">
          <div>
            <input
              type="text"
              value={this.state.searchString}
              onChange={e =>
                this.handleChatSearch(e)
              }
              placeholder="Busqueda por título o contenido"
              style={{
                width: "100%",
                borderRadius: "5px",
                marginBottom: "20px",
                border: "1px solid #ddd",
                padding: "8px 0px",
              }}
              className="form-control"
              onKeyPress={this.handleKeyPress}
            />
          </div>
          {this.state.fastAnswers.map((answer) => (
            <div className="fast_answer_content">
              <div className="pb-10 t-right c-secondary">
                <small className="select_answer" onClick={() => this.changeFastAnswer(answer)}>Seleccionar</small>
              </div>
              <small className="fs-15">{answer.attributes.title}</small>
              <div className="divider"></div>
              <div>
                {answer.attributes.image_url &&
                  <img src={answer.attributes.image_url} />
                }
              </div>
              <small className="text-pre-line">{answer.attributes.answer}</small>
            </div>
          ))}
        </div>
      </div>
    )
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
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(FastAnswers));
