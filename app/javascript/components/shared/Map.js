import React, { Component } from "react";
import Modal from 'react-modal';
import {
  Map,
  GoogleApiWrapper,
  Marker
} from 'google-maps-react';
import Loader from 'images/dashboard/loader.jpg'

const mapStyles = {
  width: '100%',
  height: '100%'
};

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    height: '80vh',
    width: '50%'
  }
};

class GoogleMap extends Component {
  constructor(props) {
    super(props)
    this.state = {
      location: {},
      loadedLocation: false
    };
  }

  onMapClicked = (mapProps, map, e) => {
    var lat = e.latLng.lat();
    var lng = e.latLng.lng();

    this.setState({
      location: { lat, lng }
    });
  }

  componentDidUpdate() {
    if (!this.props.showMap) {
      this.state.loadedLocation = false;
      return;
    }

    if (!this.state.loadedLocation && this.props.showMap) {
      navigator.geolocation.getCurrentPosition((position) => {
        if (position && position.coords && position.coords.latitude && position.coords.longitude) {
          var lat = position.coords.latitude;
          var lng = position.coords.longitude;

          this.setState({
            location: { lat, lng },
            loadedLocation: true
          });
        }
      });
    }
  }

  handleMapReady(mapProps, map) {
    map.setOptions({
      draggableCursor: "default",
      draggingCursor: "all-scroll"
    });
  }

  render() {
    return (
      <Modal appElement={document.getElementById("react_content")} isOpen={this.props.showMap} style={customStyles}>
        <div className={this.props.onMobile ? "row mt-50 mb-15" : "row mb-15" }>
          <div className="col-md-10">
            <p className={this.props.onMobile ? "fs-20 my-0" : "fs-30 my-0" }>Selecciona la ubicación</p>
            <small>Asegúrate que la ubicación marcada en el mapa es la correcta antes de enviarla</small>
          </div>
          <div className="col-md-2 t-right">
            <button onClick={() => this.props.toggleMap()}>Cerrar</button>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12 col-xs-12">
            {this.state.loadedLocation ?
              <div>
                <div className="google-map">
                  <Map
                    google={this.props.google}
                    zoom={this.props.zoomLevel}
                    style={mapStyles}
                    initialCenter = {this.state.location}
                    onClick={this.onMapClicked}
                    onReady={this.handleMapReady}
                  >
                    <Marker
                      position={this.state.location}
                    />
                  </Map>
                </div>
                <div className="row mt-10">
                  <div className="col-md-6 t-right">
                    <button onClick={() => this.props.toggleMap()}>Cancelar</button>
                  </div>
                  <div className="col-md-6 t-left">
                    <button onClick={() => this.props.sendLocation(this.state.location)}>Enviar</button>
                  </div>
                </div>
              </div>
            :
              <div className="chat_loader"><img src={Loader} /></div>
            }
          </div>
        </div>
      </Modal>
    )
  }
}

export default GoogleApiWrapper({
  apiKey: ENV['GOOGLE_API_KEY']
})(GoogleMap);
