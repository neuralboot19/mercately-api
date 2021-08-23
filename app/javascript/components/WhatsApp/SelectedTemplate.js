import React from 'react';

const SelectedTemplate = ({
  acceptedFiles,
  cancelTemplate,
  sendTemplate,
  screen,
  templateType,
  setTemplateType,
  onMobile
}) => (
  <div>
    <div className="row">
      <div className="col-md-12 text-gray-dark input-from-backend">
        {`[${setTemplateType(templateType)}] `}
        {screen}
      </div>
    </div>
    {templateType !== 'text'
        && (
          <div id="template-file" className="col-md-12">
            <br />
            <input type="file" name="file" id="template_file" accept={acceptedFiles} />
          </div>
        )}
    <div className="d-flex justify-content-center justify-content-md-end mt-30">
      <div className={onMobile ? "mr-5" : "mr-15"}>
        <a className="border-8 bg-light text-gray-dark p-12 border-gray" onClick={() => cancelTemplate()}>Cancelar</a>
      </div>
      <div className="">
        <a className="border-8 bg-blue text-white p-12" onClick={() => sendTemplate()}>Enviar</a>
      </div>
    </div>
  </div>
);

export default SelectedTemplate;
