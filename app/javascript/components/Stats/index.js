import React from 'react';
import StatsPageComponent from './statsPage';

const StatsComponent = () => {
  const renderPage = () => {
    if (ENV.SHOW_STATS) {
      return (
        <StatsPageComponent />
      )
    }
    else {
      return (
        <div className="content_width ml-sm-108 mt-25 px-15 no-left-margin-xs">
          <div className="container-fluid-no-padding">
            <div className="row">
              <div className="warning-box col-md-12 pl-10" role="alert">
                Tu plan actual (básico) no incluye este módulo. Actualiza tu plan y obten todas las estadísticas de tu negocio.
              </div>
            </div>
          </div>
        </div>
      )
    }
  }
  return (
    <>
    { renderPage() }
    </>
  );
};

export default StatsComponent;