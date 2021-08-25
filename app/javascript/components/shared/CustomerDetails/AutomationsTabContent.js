import React from 'react';
import ShowMoreText from 'react-show-more-text';
import ScheduleReminderStatus from '../ScheduleReminderStatus';

const AutomationsTabContent = ({
  reminders,
  cancelReminder,
  showAutomationSettings
}) => {
  const reminderStatus = (reminder) => {
    switch (reminder.status) {
      case 'scheduled':
        return (
          <ScheduleReminderStatus
            reminder={reminder}
            cancelReminder={cancelReminder}
          />
        );
      case 'sent':
        return <span className="cookie cookie--green fs-12 font-weight-bold" value="0">Envíado</span>;
      case 'cancelled':
        return <span className="cookie cookie--red fs-12 font-weight-bold" value="3">Cancelado</span>;
      default:
        return <span className="cookie cookie--red fs-12 font-weight-bold" value="3">Fallido</span>;
    }
  };

  return (
    <div className="custome_fields" style={{ display: showAutomationSettings }}>
      <div className="details_holder">
        <span>Recordatorios</span>
      </div>
      { (reminders.length > 0) ? (
        reminders.map((reminder) => (
          <div className="container-fluid p-0">
            <div className="bordered-container py-8 px-r-2 mb-8">
              <div className="mb-8">
                <div className=" fz-12 truncate-js">
                  <ShowMoreText
                    more="Ver más"
                    less="Ver menos"
                    expanded={false}
                  >
                    {reminder.template_text}
                  </ShowMoreText>
                  <span className="c-grey">
                    {reminder.send_at}
                  </span>
                </div>
                <div className="p-0">
                  {reminderStatus(reminder)}
                </div>
              </div>
            </div>
          </div>
        ))
      ) : (
        <div className="bordered-container py-8 px-2">
          <div className="t-center">Sin recordatorios programados</div>
        </div>
      )}
    </div>
  );
};

export default AutomationsTabContent;
