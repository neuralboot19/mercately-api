import React from 'react';

const Advice = ({html}) => {
  return(
    <div className="container-fluid-no-padding">
      <div className="row">
        <div className="warning-box col-md-12 pl-10" dangerouslySetInnerHTML={{ __html: html }} />
      </div>
    </div>
  )
}

export default Advice;