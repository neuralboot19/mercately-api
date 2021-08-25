import React from 'react';
import { useSelector } from "react-redux";
import EditableField from "./EditableField";
import SelectableField from "./SelectableField";

const CustomerDetailsTabContent = ({
  chatType,
  customerId,
  showUserDetails,
  customer,
  customerTags,
  handleEnter,
  handleInputChange,
  handleSubmit,
  handleSelectChange,
  handleSelectTagChange,
  tags,
  newTag,
  handleNewTagChange,
  onKeyPress,
  removeCustomerTag
}) => {
  const errors = useSelector((reduxState) => reduxState.errors) || {};
  return (
    <div className="customer_details" style={{ display: showUserDetails }}>
      <div>
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-user editable_name" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Nombres</p>
        </div>
        { Object.keys(customer).length !== 0 && (
          <div>
            <EditableField
              handleInputChange={handleInputChange}
              content={customer.first_name}
              givenClass="mb-6 custom-input text-gray-dark fs-14"
              handleSubmit={handleSubmit}
              targetName="first_name"
              placeholder="Nombre"
            />
            <EditableField
              handleInputChange={handleInputChange}
              content={customer.last_name}
              handleSubmit={handleSubmit}
              givenClass="mb-6 custom-input text-gray-dark fs-14"
              targetName="last_name"
              placeholder="Apellido"
            />
          </div>
        )}
      </div>
      <div>
        <div>
          <i className="fs-18 mt-4 mr-4 fab fa-whatsapp-square editable_phone" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Teléfono:</p>
        </div>
        <div className="d-flex">
          {customer.emoji_flag}
          <EditableField
            handleInputChange={handleInputChange}
            content={customer.phone}
            handleSubmit={handleSubmit}
            givenClass="mb-6 custom-input text-gray-dark fs-14"
            targetName="phone"
            placeholder="Teléfono"
          />
        </div>
      </div>
      <div className="text-gray-dark">
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-envelope-square editable_email" />
          <p className="label inline-block text-gray-dark fs-14 font-weight-bold">Email:</p>
          <small className="validation-msg">{errors.email}</small>
        </div>
        { Object.keys(customer).length !== 0 && (
          <EditableField
            handleInputChange={handleInputChange}
            content={customer.email}
            handleSubmit={handleSubmit}
            targetName="email"
            givenClass="mb-6 custom-input text-gray-dark fs-14"
            placeholder="Email"
          />
        )}
      </div>
      <div className="fs-14 text-gray-dark">
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-address-card editable_card_id" />
          <p className="label inline-block text-gray-dark font-weight-bold">Identificación:</p>
        </div>
        <SelectableField
          selected={customer.id_type}
          handleSelectChange={handleSelectChange}
        />
        <EditableField
          handleInputChange={handleInputChange}
          content={customer.id_number}
          handleSubmit={handleSubmit}
          givenClass="my-6 custom-input text-gray-dark fs-14"
          targetName="id_number"
          placeholder="Identificación"
        />
      </div>
      <div>
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-map-marked-alt editable_map" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Dirección:</p>
        </div>
        { Object.keys(customer).length !== 0 && (
          <div>
            <EditableField
              handleInputChange={handleInputChange}
              content={customer.address}
              handleSubmit={handleSubmit}
              targetName="address"
              placeholder="Dirección"
              givenClass="mb-6 custom-input text-gray-dark fs-14"
            />
            <EditableField
              handleInputChange={handleInputChange}
              content={customer.city}
              handleSubmit={handleSubmit}
              targetName="city"
              givenClass="mb-6 custom-input text-gray-dark fs-14"
              placeholder="Ciudad"
            />
            <EditableField
              handleInputChange={handleInputChange}
              content={customer.state}
              handleSubmit={handleSubmit}
              targetName="state"
              placeholder="Provincia/Estado"
              givenClass="mb-6 custom-input text-gray-dark fs-14"
            />
          </div>
        )}
      </div>

      <div>
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-tags editable_name" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Etiquetas:</p>
        </div>

        <div className="text-gray-dark fs-14">
          <SelectableField
            handleSelectTagChange={handleSelectTagChange}
            isTag
            options={tags}
          />
          <input
            className="input text-gray-dark fs-14"
            type="text"
            name="newTag"
            value={newTag}
            placeholder="Nueva etiqueta"
            maxLength="20"
            onChange={handleNewTagChange}
            onKeyPress={onKeyPress}
          />
        </div>

        <div className="container">
          <div className="row bottom-xs">
            {customerTags && customerTags.map((tag) => (
              <div key={tag.tag} className="customer-saved-tags mt-10">
                {tag.tag}
                <i
                  className="fas fa-times f-right mt-2 cursor-pointer"
                  onClick={() => removeCustomerTag(tag)}
                />
              </div>
            ))}
          </div>
        </div>

      </div>

      <div>
        <textarea
          onKeyDown={handleEnter}
          onChange={(e) => handleInputChange(e, 'notes')}
          name="notes"
          className="editable-notes w-100 text-gray-dark fs-14"
          onBlur={handleSubmit}
          placeholder="Notas"
          value={customer.notes || ''}
        />
      </div>
      <div className="t-center mt-20">
        {customerId ? (
          <a
            href={window.location.href.replace(`${chatType}`, `orders/new?customer_id=${customerId}&from=${chatType}`)}
            target="_blank"
            className="btn btn--cta"
          >
            Generar Venta
          </a>
        ) : (
          <a
            href={window.location.href.replace(`${chatType}`, `orders/new?first_name=${customer.first_name}&last_name=${customer.last_name}&email=${customer.email}&phone=${customer.phone}&from=${chatType}`)}
            target="_blank"
            className="btn btn--cta"
          >
            Generar Venta
          </a>
        )}
      </div>
    </div>
  );
};

export default CustomerDetailsTabContent;
