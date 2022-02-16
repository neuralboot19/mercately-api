import React, { useState } from 'react';
import { useDispatch, useSelector } from "react-redux";
import EditIcon from 'images/edit.svg';
import EditableField from "./EditableField";
import SelectableField from "./SelectableField";
import DealModal from '../DealModal';
import { deleteSimpleDeal } from '../../../actions/funnels';
import TrashIcon from '../../icons/TrashIcon';

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
  removeCustomerTag,
  customerDeals,
  funnelSteps,
  getCustomerDeals
}) => {
  const dispatch = useDispatch();

  const errors = useSelector((reduxState) => reduxState.mainReducer.errors) || {};
  const [isDealModalOpen, setIsDealModalOpen] = useState(false);
  const [dealSelected, setDealSelected] = useState(null);
  const agents = useSelector((reduxState) => reduxState.mainReducer.agent_list || []);

  const handleDeleteDeal = (deal) => {
    const destroy = confirm('¿Estás seguro de eliminar esta negociación?');
    if (destroy) {
      dispatch(deleteSimpleDeal(deal.web_id));
    }
  };

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
            className="input text-gray-dark fs-14 w-100"
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
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-briefcase editable_name" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Negociaciones:</p>
          { customerDeals.length == 0 && (
            <i className="fs-18 mt-4 ml-6 fas fa-plus editable_name cursor-pointer"
              title='Crear negociación'
              onClick={() => {
                setIsDealModalOpen((prevState) => !prevState);
                setDealSelected(null);
              }}>
            </i>
          )}
        </div>
        { customerDeals.map((deal, index) => (
          <div key={index} className="card">
            <div className="card-body">
              <p className="card-title fs-14 deal-name">{deal.name}</p>
              <p className="card-text fs-12 m-0">
                Estado:
                {deal.funnel_step_name}
              </p>
              { deal.amount && (
              <p className="card-text fs-12 m-0">
                Monto:
                {deal.amount}
              </p>
              )}
              <div className="chat-funnel-holder">
                <a
                  onClick={() => {
                    setIsDealModalOpen((prevState) => !prevState);
                    setDealSelected(deal);
                  }}
                  className="card-link"
                >
                  <img src={EditIcon} width="12" height="14" />
                </a>
                <a
                  onClick={() => {
                    handleDeleteDeal(deal);
                  }}
                  className="card-link"
                >
                  <TrashIcon />
                </a>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div>
        <div>
          <i className="fs-18 mt-4 mr-4 fas fa-pencil-alt editable_name" />
          <p className="label inline-block fs-14 text-gray-dark font-weight-bold">Notas:</p>
        </div>

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

      { isDealModalOpen
        ? (
          <DealModal
            customer={{ ...customer, id: customerId }}
            funnelSteps={funnelSteps}
            isDealModalOpen={isDealModalOpen}
            toggleDealModal={() => setIsDealModalOpen((prevState) => !prevState)}
            dealSelected={dealSelected}
            agents={agents}
            getCustomerDeals={getCustomerDeals}
            handleDeleteDeal={handleDeleteDeal}
          />
        )
        : false}
    </div>
  );
};

export default CustomerDetailsTabContent;
