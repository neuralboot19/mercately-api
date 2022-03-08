import React from 'react';

const SidebarModal = ({ id, title, ...props }) => (
  <div className="modal right fade m-0" id={id} role="dialog" style={{ backdropFilter: 'blur(9px)' }}>
    <div className="modal-dialog" role="document">
      <div className="modal-content">
        <div className="modal-header bg-white not-border-bottom mt-38 ml-18 mr-18">
          <h4 className="modal-title funnels-modal-title">{title}</h4>
          <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        </div>
        <div className="modal-body">
          {props.children}
        </div>
      </div>
    </div>
  </div>
);

export default SidebarModal;