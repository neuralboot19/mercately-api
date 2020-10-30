import React, { Component } from 'react';

class Message extends Component {
  constructor(props) {
    super(props)
  }

  downloadFile = (e, file_url, filename) => {
    e.preventDefault();
    var link = document.createElement('a');
    link.href = file_url;
    link.target = '_blank';
    link.download = filename;
    link.click();
  }

  timeMessage = (message) => {
    return (
      <span className={message.direction == 'inbound' ? 'fs-10 mt-3 c-gray-label' : 'fs-10 mt-3'}>{moment(message.created_time).local().locale('es').format('DD-MM-YYYY HH:mm')}</span>
    )
  }

  render() {
    return (
      <div>
        {this.props.message.replied_message &&
          <div className="replied-message mb-10">
            {this.props.message.replied_message.data.attributes.content_type == 'text' &&
              <span className="text text-pre-line">{this.props.message.replied_message.data.attributes.content_text}</span>
            }
            {this.props.message.replied_message.data.attributes.content_type == 'media' && this.props.message.replied_message.data.attributes.content_media_type == 'image' &&
              <img src={this.props.message.replied_message.data.attributes.content_media_url} className="image"
                onClick={(e) => this.props.toggleImgModal(e)}/>
            }
            {this.props.message.replied_message.data.attributes.content_type == 'media' && (this.props.message.replied_message.data.attributes.content_media_type == 'voice' || this.props.message.replied_message.data.attributes.content_media_type == 'audio') && (
              <audio controls>
                <source src={this.props.message.replied_message.data.attributes.content_media_url}/>
              </audio>
            )}
            {this.props.message.replied_message.data.attributes.content_type == 'media' && this.props.message.replied_message.data.attributes.content_media_type == 'video' && (
              <video width="120" height="80" controls>
                <source src={this.props.message.replied_message.data.attributes.content_media_url}/>
              </video>
            )}
            {this.props.message.replied_message.data.attributes.content_type == 'location' &&
                (<div className="fs-15 no-back-color"><a href={`https://www.google.com/maps/place/${this.props.message.replied_message.data.attributes.content_location_latitude},${this.props.message.replied_message.data.attributes.content_location_longitude}`} target="_blank">
                  <i className="fas fa-map-marker-alt mr-8"></i>Ver ubicación</a></div>)}
            {this.props.message.replied_message.data.attributes.content_type == 'media' && this.props.message.replied_message.data.attributes.content_media_type == 'document' && (
              <div className="fs-15 no-back-color"><a href="" onClick={(e) => this.downloadFile(e, this.props.message.replied_message.data.attributes.content_media_url, this.props.message.replied_message.data.attributes.content_media_caption)}><i className="fas fa-file-download mr-8"></i>{this.props.message.replied_message.data.attributes.content_media_caption || 'Descargar archivo'}</a></div>
            )}
            {this.props.message.replied_message.data.attributes.content_type == 'contact' &&
              this.props.message.replied_message.data.attributes.contacts_information.map(contact =>
                <div className="contact-card w-100 mb-10 no-back-color">
                  <div className="w-100 mb-10"><i className="fas fa-user mr-8"></i>{contact.names.formatted_name}</div>
                  {contact.phones.map(ph =>
                    <div className="w-100 fs-14"><i className="fas fa-phone-square-alt mr-8"></i>{ph.phone}</div>
                  )}
                  {contact.emails.map(em =>
                    <div className="w-100 fs-14"><i className="fas fa-at mr-8"></i>{em.email}</div>
                  )}
                  {contact.addresses.map(addrr =>
                    <div className="w-100 fs-14"><i className="fas fa-map-marker-alt mr-8"></i>{addrr.street ? addrr.street : (addrr.city + ', ' + addrr.state + ', ' + addrr.country)}</div>
                  )}
                  {contact.org && contact.org.company &&
                    <div className="w-100 fs-14"><i className="fas fa-building mr-8"></i>{contact.org.company}</div>
                  }
                </div>
              )
            }
          </div>
        }
        {this.props.message.content_type == 'text' &&
          <div className="text-pre-line">
            {this.props.message.content_text}
            <br />
            <div className="f-right">
              {this.timeMessage(this.props.message)}
              {this.props.message.direction == 'outbound' && this.props.handleMessageEvents === true  &&
                <i className={ `checks-mark ml-7 fas fa-${
                  this.props.message.status === 'sent' ? 'check stroke' : (this.props.message.status === 'delivered' ? 'check-double stroke' : ( this.props.message.status === 'read' ? 'check-double read' : 'sync'))
                }`
                }></i>
              }
            </div>
          </div>
        }
        {this.props.message.content_type == 'media' && this.props.message.content_media_type == 'image' &&
            (<div className="img-holder">
              <img src={this.props.message.content_media_url} className="msg__img"
                onClick={(e) => this.props.toggleImgModal(e)}/>
              {this.props.message.is_loading && (
                <div className="lds-dual-ring"></div>
              )}
            </div>)}
        {this.props.message.content_type == 'media' && (this.props.message.content_media_type == 'voice' || this.props.message.content_media_type == 'audio') && (
          <audio controls>
            <source src={this.props.message.content_media_url}/>
          </audio>
        )}
        {this.props.message.content_type == 'media' && this.props.message.content_media_type == 'video' && (
          <video width="320" height="240" controls>
            <source src={this.props.message.content_media_url}/>
          </video>
        )}
        {this.props.message.content_type == 'location' &&
            (<div className="fs-15"><a href={`https://www.google.com/maps/place/${this.props.message.content_location_latitude},${this.props.message.content_location_longitude}`} target="_blank">
              <i className="fas fa-map-marker-alt mr-8"></i>Ver ubicación</a></div>)}
        {this.props.message.content_type == 'media' && this.props.message.content_media_type == 'document' && (
          <div className="fs-15"><a href="" onClick={(e) => this.downloadFile(e, this.props.message.content_media_url, this.props.message.content_media_caption)}><i className="fas fa-file-download mr-8"></i>{this.props.message.content_media_caption || 'Descargar archivo'}</a></div>
        )}
        {this.props.message.content_media_caption && this.props.message.content_media_type !== 'document' &&
          (<div className="caption text-pre-line">{this.props.message.content_media_caption}</div>)}
        {this.props.message.content_type == 'contact' &&
          this.props.message.contacts_information.map(contact =>
            <div className="contact-card w-100 mb-10">
              <div className="w-100 mb-10"><i className="fas fa-user mr-8"></i>{contact.names.formatted_name}</div>
              {contact.phones.map(ph =>
                <div className="w-100 fs-14"><i className="fas fa-phone-square-alt mr-8"></i>{ph.phone}</div>
              )}
              {contact.emails.map(em =>
                <div className="w-100 fs-14"><i className="fas fa-at mr-8"></i>{em.email}</div>
              )}
              {contact.addresses.map(addrr =>
                <div className="w-100 fs-14"><i className="fas fa-map-marker-alt mr-8"></i>{addrr.street ? addrr.street : (addrr.city + ', ' + addrr.state + ', ' + addrr.country)}</div>
              )}
              {contact.org && contact.org.company &&
                <div className="w-100 fs-14"><i className="fas fa-building mr-8"></i>{contact.org.company}</div>
              }
            </div>
          )
        }
      </div>
    )
  }
}

export default Message
