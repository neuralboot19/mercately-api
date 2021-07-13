import React from 'react';
// eslint-disable-next-line import/no-unresolved
import TemplateImg from 'images/dashboard/ilustracion-cel.png';

const WithoutTemplate = () => (
  <div className="row text-gray-dark">
    <div className="col-md-6 col-xs-12">
      <img src={TemplateImg} className="pt-36" />
    </div>
    <div className="col-xs-12 col-md-6 t-justify">
      <h2 className="text-blue">
        ¿Qué son las <b>plantillas</b>?
      </h2>
      Las plantillas de mensajería de WhatsApp son <b>mensajes preaprobados</b> por WhatsApp para que puedas <b>iniciar una conversación</b> o retomar una conversación con tus clientes.
      <br/>
      <br/>
      <h2 className="text-blue">Contenido</h2>
      <ul className="list-checks">
        <li>
          Las plantillas se basan en <b>texto</b> y solo deben contener <b>letras</b>
        </li>
        <li>
          <b>No</b> puede contener <b>más de 1024 caracteres</b>
        </li>
        <li>
          No puede incluir lineas extra, pestañas, o más de cuatro espacios consecutivos
        </li>
      </ul>
      <div className="t-center">
        <br />
        <a href={`/retailers/${window.location.pathname.split('/')[2]}/gs_templates`} className="btn btn--cta">
          <i className="fas fa-plus mr-5"></i>
          &nbsp;&nbsp;&nbsp;Crear mi primera plantilla&nbsp;&nbsp;
        </a>
        <br />
        <br />
        <a className="btn btn--cta" target="_blank" href="https://mercately.crunch.help/integraciones/como-crear-plantillas-de-whats-app-hsm">
          <i className="fas fa-book-open mr-5"></i>
          Instrucciones y limitaciones
        </a>
        <br />
        <br />
      </div>
    </div>
  </div>
);

export default WithoutTemplate;
