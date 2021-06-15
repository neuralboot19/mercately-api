import React from "react";
import OpportunityClient from "./OpportunityClient";

class InnerList extends React.Component {
  shouldComponentUpdate(nextProps) {
    return nextProps.deals !== this.props.deals;
  }

  render() {
    return this.props.deals.map((deal, index) => (
      <OpportunityClient key={deal.id} deal={deal} index={index} />
    ));
  }
}

export default InnerList;
