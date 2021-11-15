import React, {useState, useEffect, useRef} from 'react';
import Select from 'react-select';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { createGsTemplate } from '../../actions/gsTemplatesActions';

import AttachEmojiIcon from "../shared/AttachEmojiIcon";
import EmojisContainer from "../shared/EmojisContainer";
import stringUtils from '../../util/string.utils';

const csrfToken = document.querySelector('[name=csrf-token]').content;

const categories = [
  { value: 'ACCOUNT_UPDATE', label: 'ACCOUNT_UPDATE' },
  { value: 'PAYMENT_UPDATE', label: 'PAYMENT_UPDATE' },
  { value: 'PERSONAL_FINANCE_UPDATE', label: 'PERSONAL_FINANCE_UPDATE' },
  { value: 'SHIPPING_UPDATE', label: 'SHIPPING_UPDATE' },
  { value: 'RESERVATION_UPDATE', label: 'RESERVATION_UPDATE' },
  { value: 'ISSUE_RESOLUTION', label: 'ISSUE_RESOLUTION' },
  { value: 'APPOINTMENT_UPDATE', label: 'APPOINTMENT_UPDATE' },
  { value: 'TRANSFORMATION_UPDATE', label: 'TRANSFORMATION_UPDATE' },
  { value: 'TICKET_UPDATE', label: 'TICKET_UPDATE' },
  { value: 'ALERT_UPDATE', label: 'ALERT_UPDATE' },
  { value: 'AUTO_REPLY', label: 'AUTO_REPLY' }
];

const languages = [
  { value: 'spanish', label: 'Español' },
  { value: 'english', label: 'Inglés' }
];

const gsTemplatesTypes = [
  { value: 'text', label: 'TEXTO' },
  { value: 'image', label: 'IMAGEN' },
  { value: 'document', label: 'DOCUMENTO' }
];

const GsTemplatesNew = (props) => {
  const [label, setLabel] = useState('');
  const [category, setCategory] = useState(categories[0]);
  const [language, setLanguage] = useState(languages[0]);
  const [type, setType] = useState(gsTemplatesTypes[0]);
  const [templateText, setTemplateText] = useState('');
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [caretPosition, setCaretPosition] = useState(0);
  const [templateValues, setTemplateValues] = useState({});
  const [emoji, setEmoji] = useState(null);
  const [selectedFile, setSelectedFile] = useState(null);

  const templateTextRef = useRef(null);

  const dispatch = useDispatch();
  
  const toggleEmojiPicker = () => {
    setShowEmojiPicker(!showEmojiPicker);
    templateTextRef.current.focus();
  };

  const insertEmoji = (emoji) => {
    let _emoji = emoji.native;
    const cursor = templateTextRef.current.selectionStart;
    const text = templateText.slice(0, cursor) + _emoji + templateText.slice(cursor);
    setEmoji(emoji);
    setTemplateText(text);
    setCaretPosition(cursor);
    templateTextRef.current.focus();
  }

  const handleInputLabel = () => {
    let newLabelText = label;
    newLabelText = newLabelText.replace(/ /g, "_");
    newLabelText = newLabelText.toLowerCase();
    newLabelText = newLabelText.replace(/[^a-z0-9_]/gi, '');

    setLabel(newLabelText);
  }

  useEffect(() => {
    templateTextRef.current.selectionStart = caretPosition;
    templateTextRef.current.selectionEnd = caretPosition;

    if (emoji) {
      templateTextRef.current.selectionStart = caretPosition + emoji.native.length;
      templateTextRef.current.selectionEnd = caretPosition + emoji.native.length;
    }
  }, [emoji, caretPosition]);

  const getId = (key) => {
    return key.replaceAll('{{', '').replaceAll('}}', '');
  }

  const renderTemplateExample = () => {
    let currentText = templateText;
    let textArray = currentText.split(/({{[1-9]+[0-9]*}})/g);

    if (!textArray) {
      return;
    }
  
    return textArray.map((key, index) => {
      if (/{{[1-9]+[0-9]*}}/.test(key)) {
        const id = getId(key);
        return(
          <input key={index}
                 value={templateValues[id] || ''}
                 onChange={e => setTemplateValues({...templateValues, [id]: e.target.value})}
                 required={true} />
        );
      }
      else {
        return(<span key={index}>{key}</span>);
      }
    });
  }

  const handleValidation = () => {
    let errors = {};
    let formIsValid = true;

    if (!label) {
      formIsValid = false;
      errors["label"] = ['no puede estar vacio'];
    }

    if (!templateText) {
      formIsValid = false;
      errors["text"] = ['no puede estar vacio'];
    }

    if (!formIsValid) {
      dispatch({ type: 'SET_GS_TEMPLATE_ERRORS', errors });
    }

    return formIsValid;
  }

  const submitGsTemplate = (evt) => {
    evt.preventDefault();

    if (!handleValidation()) {
      return;
    }

    let exampleText = templateText;

    Object.entries(templateValues).forEach(([key, value]) => {
      exampleText = exampleText.replace(`{{${key}}}`, `[${value}]`);
    })

    const formData  = new FormData();

    formData.append('gs_template[label]', label);
    formData.append('gs_template[category]', category.value);
    formData.append('gs_template[language]', language.value);
    formData.append('gs_template[key]', type.value);
    formData.append('gs_template[text]', templateText);
    formData.append('gs_template[example]', exampleText);

    if (type.value == 'image' || type.value == 'document') {
      if (!selectedFile) {
        alert('Seleccione una imagen o ducumento pdf');
        return;
      }

      let alertMessage;

      switch (type.value) {
        case 'image':
          if (!['image/jpg', 'image/jpeg', 'image/png'].includes(selectedFile.type)) {
            alertMessage = 'Imágenes permitidos: jpg, jpeg, png';
          }
          break;
        case 'document':
          if (selectedFile.type !== 'application/pdf') {
            alertMessage = 'Debe seleccionar un documento pdf';
          }
          break;
      }
      
      if (alertMessage) {
        alert(alertMessage);
        setSelectedFile(null);
        return;
      }

      formData.append('gs_template[file]', selectedFile);
    }

    dispatch({ type: 'TOGGLE_SUBMITTED', submitted: true });
    props.createGsTemplate(formData, csrfToken);
  }

  const renderButtonLabel = () => {
    switch (type.value) {
      case 'image':
        return (
          <label className="btn btn--cta label-for ml-0">
            <i className="fas fa-upload mr-5"></i>
            Agregar Imagen
          </label>
        )
      case 'document':
        return (
          <label className="btn btn--cta label-for ml-0">
            <i className="fas fa-upload mr-5"></i>
            Agregar Documento
          </label>
        )
      default:
        return false;
    }
  }

  const renderPreviewFile = () => {
    if (selectedFile) {
      switch (selectedFile.type) {
        case 'image/jpg':
        case 'image/jpeg':
        case 'image/png':
          return (
            <div className="p-relative w-50 mt-10">
              <i className="fas fa-times-circle cursor-pointer delete-icon-right" style={{ zIndex: '0' }} onClick={() => setSelectedFile(null)}></i>
              <img src={URL.createObjectURL(selectedFile)} className="h-100" />
            </div>
          )
        case 'application/pdf':
          return (
            <div className="p-relative mt-10">
                <i className="fas fa-file-pdf mr-8"></i>
                <span className="c-secondary fs-14">{stringUtils.truncate(selectedFile.name, 40)}</span>
                <i className="fas fa-times-circle cursor-pointer delete-icon-right ml-5" style={{ zIndex: '0', position: 'relative' }} onClick={() => setSelectedFile(null)}></i>
            </div>
          )
      }
    }

    return false;
  }

  const handleInputFile = (e) => {
    if (e.target.files && e.target.files.length > 0) {
      setSelectedFile(e.target.files[0]);
    }
  }

  const renderInputFile = () => {
    switch (type.value) {
      case 'image':
        return (
          <>
            <div className="custom-file" style={{ zIndex: 0}}>
              <input type="file" className="custom-file-input" accept="image/jpg, image/jpeg, image/png" onChange={handleInputFile} />
              {renderButtonLabel()}
            </div>
            {renderPreviewFile()}
          </>
        )
      case 'document':
        return (
          <>
            <div className="custom-file" style={{ zIndex: 0}}>
              <input type="file" className="custom-file-input" accept="application/pdf" onChange={handleInputFile} />
              {renderButtonLabel()}
            </div>
            {renderPreviewFile()}
          </>
        )
    }

    return false;
  }

  return (
    <div className="wrapper-container">
      <div className="ibox">
        <div className="ibox-title">
          <div className="col-xs-12 col-md-4 p-0">
            <a className="class: back-link m-0" href="/retailers/gupshup-retailer/gs_templates?q%5Bs%5D=created_at+desc">
              <i className="fas fa-caret-left mr-5"></i>
                Plantillas de WhatsApp
              </a>
            <h1 className="page-title">Crear plantilla</h1>
          </div>
        </div>

        <div className="ibox-content">
          <div className="card-title">
            <h5 className="form-container_sub-title ml-0">Plantilla de WhatsApp</h5>
          </div>
          <form onSubmit={submitGsTemplate}>
            <div className="card-body p-0">
              <div className="box">
                <div className="form-container">
                  <div className="row">
                    <div className="col-md-3 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="label" className="form-label">Etiqueta</label>
                        <input id="label"
                               type="text"
                               name="label"
                               className="form-control"
                               value={label}
                               onKeyUp={handleInputLabel}
                               onChange={e => setLabel(e.target.value)} />
                        {props.labelValidationText? <i className="validation-msg capitalize">{props.labelValidationText}<br/></i>: null}
                        <i className="tag-description">(Solo se permiten letras minusculas, caracteres alfanumericos y guiones bajos(_))</i>
                      </div>
                    </div>

                    <div className="col-md-3 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="category" className="form-label">Categoría</label>
                        <Select options={categories}
                                value={category}
                                onChange={value => setCategory(value)} />
                      </div>
                    </div>

                    <div className="col-md-3 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="language" className="form-label">Idioma</label>
                        <Select options={languages}
                                value={language}
                                onChange={value => setLanguage(value)} />
                      </div>
                    </div>

                    <div className="col-md-3 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="type" className="form-label">Tipo</label>
                        <Select options={gsTemplatesTypes}
                                value={type}
                                onChange={value => {setType(value); setSelectedFile(null);}} />
                      </div>

                      {renderInputFile()}
                    </div>
                  </div>

                  <div className="row">
                    <div className="col-md-6 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="templateText" className="form-label">Texto de la plantilla</label>
                        <div className="emojis-container-textarea">
                          <div className="emoji-icon">
                            {showEmojiPicker
                            && (
                              <EmojisContainer insertEmoji={insertEmoji} />
                            )}
                            <AttachEmojiIcon toggleEmojiPicker={toggleEmojiPicker} />
                          </div>
                          <textarea ref={templateTextRef}
                                    value={templateText}
                                    onChange={e => setTemplateText(e.target.value)}
                                    className="form-control textarea-form"
                                    style={{ height:'128px'}} />
                          {props.textValidationText? <i className="validation-msg capitalize">{props.textValidationText}<br/></i>: null}
                        </div>
                        <i className="tag-description">
                          (Las variables deben ser números (a partir del 1) encerrados entre llaves dobles)
                          <br/>
                          Ejemplo: Buenas tardes <b>{"{{1}}"}</b>, tu compra será entragada a las <b>{"{{2}}"}</b>
                        </i>
                      </div>
                    </div>

                    <div className="col-md-6 col-sm-6 col-xs-12">
                      <div className="form-group">
                        <label htmlFor="templateExample" className="form-label">Ejemplo de la plantilla</label>
                        <div id="template-example" className="template-example-container text-pre-line">{renderTemplateExample()}</div>
                        <i className="tag-description">
                          (Un mensaje de muestra debe ser un mensaje completo que reemplace el marcador de posición dado en la plantilla con una palabra / declaración / números / caracteres especiales significativos.)
                          <br/>
                          Ejemplo: Buenas tardes <b>[Michael]</b>, tu compra será entragada a las <b>[14h00 del dia de hoy]</b>
                        </i>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="card-foot">
              <div className="row">
                <div className="col-md-12 text-right p-0">
                  <a className="cancel-link mr-30" href="/retailers/gupshup-retailer/gs_templates?q%5Bs%5D=created_at+desc">Cancelar</a>
                  <button type="submit"
                          className="btn-btn btn-submit btn-primary-style"
                          disabled={props.submitted}>
                      { props.submitted && <span className="pr-5"><i className="fas fa-spinner"></i></span> }
                    Guardar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}

function mapStateToProps(state) {
  return {
    labelValidationText: state.labelValidationText,
    textValidationText: state.textValidationText,
    submitted: state.submitted
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    createGsTemplate: (contactGroup, token) => {
      dispatch(createGsTemplate(contactGroup, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withRouter(GsTemplatesNew));