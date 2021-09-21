import React from 'react';
// eslint-disable-next-line import/no-unresolved
import NoteIcon from 'images/new_design/note.svg';

const OpenNoteModalButton = ({ openNoteModal }) => (
  <div className="d-inline-block">
    <div onClick={openNoteModal} className="rounded-pill border border-gray ml-12 cursor-pointer fs-12 p-10 mb-16">
      <img className="mr-4" src={NoteIcon} alt="Crear nota" />
      <span>Crear nota</span>
    </div>
  </div>
);

export default OpenNoteModalButton;
