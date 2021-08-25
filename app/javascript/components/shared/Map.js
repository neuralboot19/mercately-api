import React, { Component } from "react";
import Modal from 'react-modal';
import {
  Map,
  GoogleApiWrapper,
  Marker
} from 'google-maps-react';
import Loader from 'images/dashboard/loader.jpg'
import modalCustomStyles from '../../util/modalCustomStyles';
import CloseIcon from '../icons/CloseIcon';

const mapStyles = {
  width: '100%',
  height: '100%'
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
    const fsTitle = this.props.onMobile ? 'fs-16' : 'fs-24';
    return (
      <Modal appElement={document.getElementById("react_content")} isOpen={this.props.showMap} style={modalCustomStyles(this.props.onMobile)}>
        <div className={this.props.onMobile ? "d-flex justify-content-between align-items-center mb-15" : "d-flex justify-content-between align-items-center mb-15" }>
          <div className="text-gray-dark font-weight-bold">
            <p className={`font-weight-bold m-0 ${fsTitle}`}>Selecciona la ubicación</p>
            <small className="d-none d-md-block">Asegúrate que la ubicación marcada en el mapa es la correcta antes de enviarla</small>
          </div>
          <div>
            <a className="px-8" onClick={() => this.props.toggleMap()}>
              <CloseIcon className="fill-dark" />
            </a>
          </div>
        </div>
        <small className="d-md-none mb-10">Asegúrate que la ubicación marcada en el mapa es la correcta antes de enviarla</small>
        <div>
          <div >
            {this.state.loadedLocation ?
              <div>
                <div className="google-map mb-20">
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
                <div className="d-flex justify-content-center">
                  <div className={this.props.onMobile ? "mr-5" : "mr-15"}>
                    <a className="border-8 bg-light p-12 text-gray-dark border-gray" onClick={() => this.props.toggleMap()}>Cancelar</a>
                  </div>
                  <div>
                    <a className="border-8 bg-blue text-white p-12" onClick={() => this.props.sendLocation(this.state.location)}>Enviar</a>
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
