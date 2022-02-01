import React from 'react';
import Modal from 'react-modal';
import { registerLocale } from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import es from 'date-fns/locale/es';
import ReminderTemplateItem from './ReminderTemplateItem';
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';
import WithoutTemplate from './WithoutTemplate';
import SelectedReminderTemplate from './SelectedReminderTemplate';

registerLocale('es', es);

function ReminderConfigModal({
  acceptedFiles,
  cancelTemplate,
  getCleanTemplate,
  isTemplateSelected,
  onMobile,
  screen,
  selectTemplate,
  submitReminder,
  setTemplateType,
  templates,
  templateType,
  isReminderConfigModalOpen,
  toggleReminderConfigModal
}) {
  const fsTitle = onMobile ? 'fs-16' : 'fs-24';

  return (
    <Modal appElement={document.getElementById("react_content")} isOpen={isReminderConfigModalOpen} style={modalCustomStyles(onMobile)}>
      <div className="d-flex justify-content-between">
        <div>
          <p className={`font-weight-bold ${fsTitle}`}>
            Configurar recordatorio
          </p>
        </div>
        <div>
          <a className="px-8" type="button" onClick={() => toggleReminderConfigModal()}>
            <CloseIcon className="fill-dark" />
          </a>
        </div>
      </div>
      { !isTemplateSelected
        ? (
          <div>
            {
              templates.length > 0
                ? (templates.map((template) => (
                  <ReminderTemplateItem
                    key={template.id}
                    template={template}
                    getCleanTemplate={getCleanTemplate}
                    selectTemplate={selectTemplate}
                    setTemplateType={setTemplateType}
                    onMobile={onMobile}
                  />
                )))
                : <WithoutTemplate />
            }
          </div>
        ) : (
          <SelectedReminderTemplate
            acceptedFiles={acceptedFiles}
            cancelTemplate={cancelTemplate}
            screen={screen}
            templateType={templateType}
            setTemplateType={setTemplateType}
            onMobile={onMobile}
            submitReminder={submitReminder}
          />
        )}
    </Modal>
  );
}

export default ReminderConfigModal;
