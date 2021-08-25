import React from 'react';
import Modal from 'react-modal';
import TemplateSelectionItem from './TemplateSelectionItem';
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';
import WithoutTemplate from './WithoutTemplate';
import SelectedTemplate from './SelectedTemplate';

const TemplateSelectionModal = (
  {
    acceptedFiles,
    cancelTemplate,
    getCleanTemplate,
    isModalOpen,
    isTemplateSelected,
    onMobile,
    screen,
    selectTemplate,
    sendTemplate,
    setTemplateType,
    templates,
    templateType,
    toggleModal
  }
) => {
  const fsTitle = onMobile ? 'fs-16' : 'fs-24';
  return (
    <Modal appElement={document.getElementById("react_content")} isOpen={isModalOpen} style={modalCustomStyles(onMobile)}>
      <div className={onMobile ? "d-flex justify-content-between" : "d-flex justify-content-between"}>
        <div>
          <p className={`font-weight-bold font-gray-dark ${fsTitle}`}>
            {
              templates.length === 0
                ? 'No tienes plantillas creadas'
                : 'Plantillas'
            }
          </p>
        </div>
        <div>
          <a className="px-8" onClick={() => toggleModal()}>
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
                  <TemplateSelectionItem
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
        )
        : <SelectedTemplate
            acceptedFiles={acceptedFiles}
            cancelTemplate={cancelTemplate}
            sendTemplate={sendTemplate}
            screen={screen}
            templateType={templateType}
            setTemplateType={setTemplateType}
            onMobile={onMobile}
          />
      }
    </Modal>
  );
}

export default TemplateSelectionModal;
