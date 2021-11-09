import React, { Component } from "react";
import { connect } from "react-redux";
import { withRouter } from "react-router-dom";
import { getProducts } from "../../actions/actions";

const csrfToken = document.querySelector('[name=csrf-token]').content

class Products extends Component {
  constructor(props) {
    super(props)
    this.state = {
      products: [],
      page: 1,
      search: '',
      shouldUpdate: true
    };
  }

  componentDidMount() {
    this.props.getProducts();
  }

  componentDidUpdate() {
    if (this.state.shouldUpdate) {
      this.setState({
        products: this.props.products,
        shouldUpdate: false
      })
    }
  }

  componentWillReceiveProps(newProps) {
    if (newProps.products != this.props.products) {
      this.setState({
        products: this.state.products.concat(newProps.products)
      })
    }
  }

  handleChatSearch = (e) => {
    let value;
    value = e.target.value;
    this.setState({
      search: value,
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
    this.setState({products: [], page: 1}, () => {
      this.props.getProducts(1, this.state.search);
    })
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
      this.props.getProducts(page, this.state.search);
    }
  }

  toggleProducts = () => {
    this.props.toggleProducts();
  }

  render() {
    return (
      <div className={this.props.onMobile ? "customer_sidebar chat-right-side-selector no-border-left" : "customer_sidebar chat-right-side-selector" } onScroll={(e) => this.handleLoadMoreOnScrollToBottom(e)}>
        <div className="customer_box">
          <p>
            Productos
            <i className="fs-18 mt-4 mr-4 f-right fas fa-times cursor-pointer" onClick={() => this.toggleProducts()}></i>
          </p>
        </div>
        <div className="customer_details details-mobile-height col-xs-12 col-sm-12 col-md-12 col-lg-12">
          <div>
            <input
              type="text"
              value={this.state.search}
              onChange={e =>
                this.handleChatSearch(e)
              }
              placeholder="Busqueda por título o descripción"
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
          {this.state.products.map((product, index) => (
            <div key={index} className="product-right-side-content">
              <div className="d-inline-flex">
                <div className="products__img">
                  {product.attributes.image ?
                    <img src={product.attributes.image} /> : <i className="fas fa-camera-retro fs-40 c-grey"></i>
                  }
                </div>
                <div className="info-container truncate ml-10">
                  <small className="fs-12 c-primary">{product.attributes.title}</small><br />
                  <small className="fs-10">{product.attributes.description}</small><br />
                  <small className="fs-12">{product.attributes.currency}{product.attributes.price} - {product.attributes.available_quantity} disponibles</small>
                </div>
              </div>
              <div className="select-container t-center mt-15">
                <a onClick={() => this.props.selectProduct(product)}>Seleccionar</a>
              </div>
            </div>
          ))}
        </div>
      </div>
    )
  }
}

function mapState(state) {
  return {
    products: state.products || [],
    total_pages: state.total_pages
  };
}

function mapDispatch(dispatch) {
  return {
    getProducts: (page = 1, params) => {
      dispatch(getProducts(page, params));
    }
  };
}

export default connect(
  mapState,
  mapDispatch
)(withRouter(Products));
