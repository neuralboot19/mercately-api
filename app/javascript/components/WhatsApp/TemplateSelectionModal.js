import React from 'react';
import Modal from 'react-modal';

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

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
) => (
  <Modal isOpen={isModalOpen} style={customStyles}>
    <div className={onMobile ? "row mt-50" : "row"}>
      <div className="col-md-10">
        <p className={onMobile ? "fs-20 mt-0" : "fs-30 mt-0"}>Plantillas</p>
      </div>
      <div className="col-md-2 t-right">
        <button type="button" onClick={() => toggleModal()}>Cerrar</button>
      </div>
    </div>
    { !isTemplateSelected
      ? (
        <div>
          {templates.map((template) => (
            <div className="row" key={template.id}>
              <div className={onMobile ? "col-md-10 fs-10" : "col-md-10"}>
                <p>
                  {`[${setTemplateType(template.template_type)}] `}
                  {getCleanTemplate(template.text)}
                </p>
              </div>
              <div className="col-md-2">
                <button type="submit" onClick={() => selectTemplate(template)}>Seleccionar</button>
              </div>
            </div>
          ))}
        </div>
      )
      : (
        <div>
          <div className="row">
            <div className="col-md-12">
              {`[${setTemplateType(templateType)}] `}
              {screen}
            </div>
          </div>
          {templateType !== 'text'
          && (
            <div id="template-file">
              <br />
              <input type="file" name="file" id="template_file" accept={acceptedFiles} />
            </div>
          )}
          <div className="row mt-30">
            <div className="col-md-6 t-right">
              <button type="button" onClick={() => cancelTemplate()}>Cancelar</button>
            </div>
            <div className="col-md-6 t-left">
              <button type="button" onClick={() => sendTemplate()}>Enviar</button>
            </div>
          </div>
        </div>
      )}
  </Modal>
);

export default TemplateSelectionModal;
