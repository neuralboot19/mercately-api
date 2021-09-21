import React from 'react';
import moment from 'moment';

const NotesTabContent = ({
  showNotes,
  notes
}) => {
  const renderNotes = () => (
    notes.map((note) => {
      const formattedDateTime = moment(note.created_at).local().locale('es').format('DD-MM-YYYY HH:mm');
      return (
        <div key={note.id} className="message">
          <div className="message-by-retailer main-message-container note-message mw-100 w-100">
            <p className="m-0">{note.message}</p>
            <div className="text-right">
              <div className="d-inline fs-10">
                <span className="mt-3">{formattedDateTime}</span>
              </div>
            </div>
            <p className="m-0 text-right">
              <small>
                Creado por: {note.retailer_user}
              </small>
            </p>
          </div>
        </div>
      );
    }, this)
  );

  return (
    <div className="custome_fields" style={{ display: showNotes }}>
      <div className="details_holder">
        <span>Notas</span>
      </div>
      <div>
        {notes && renderNotes() }
      </div>
    </div>
  );
};

export default NotesTabContent;
