import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import {
  fetchCustomers,
  fetchSelectedCustomers,
  fetchDefaultSelectedCustomers,
  fetchTags,
  createContactGroup,
  updateContactGroup
} from '../../actions/ContactGroupActions';
import TabSelector from './TabSelector';
import CustomersTabContent from './CustomersTabContent';
import SelectedCustomersTabContent from './SelectedCustomersTabContent';

const csrfToken = document.querySelector('[name=csrf-token]').content;
const id = window.location.pathname.split('/')[4];

class ContactGroup extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      customersSearch: '',
      selectedCustomersSearch: '',
      tabSelected: 'customers',
      checkedCustomerIds: [],
      checkedSelectedCustomerIds: [],
      selectedCustomerIds: [0],
      customersTags: [],
      selectedCustomersTags: [],
      currentCustomersPage: 0,
      currentSelectedCustomersPage: 0
    };
  }

  componentDidMount() {
    this.props.fetchTags();
    if (this.props.location.pathname.split('/').pop() === 'edit') {
      this.props.fetchDefaultSelectedCustomers(id, 1);
    } else {
      this.props.fetchCustomers(1, { 'q[id_not_in]': this.state.selectedCustomerIds });
    }
  }

  componentDidUpdate(prevProps) {
    // Manejar correctamente la actualizacion de la pagina actual en cada pestaña
    if (this.state.currentCustomersPage + 1 > this.props.totalPages && this.props.totalPages !== 0) {
      this.setState(
        { currentCustomersPage: this.props.totalPages - 1 },
        () => {
          this.props.fetchCustomers(
            this.state.currentCustomersPage + 1,
            {
              'q[id_not_in]': this.state.selectedCustomerIds,
              'q[name_phone_email_cont]': this.state.customersSearch || 'none',
              'q[customer_tags_tag_id_in_all]': this.state.customersTags.length > 0 ? this.state.customersTags : 'none'
            }
          );
        }
      );
    }
    if (this.state.currentSelectedCustomersPage + 1 > this.props.totalSelectedCustomersPages && this.props.totalSelectedCustomersPages !== 0) {
      this.setState(
        { currentSelectedCustomersPage: this.props.totalSelectedCustomersPages - 1 },
        () => {
          this.props.fetchCustomers(
            this.state.currentSelectedCustomersPage + 1,
            {
              'q[id_not_in]': this.state.selectedCustomerIds,
              'q[name_phone_email_cont]': this.state.selectedCustomersSearch || 'none',
              'q[customer_tags_tag_id_in_all]': this.state.selectedCustomersTags.length > 0 ? this.state.selectedCustomersTags : 'none'
            }
          );
        }
      );
    }

    // Hacer un fetch en el edit de los customers que no estan en el ContactGroup
    if (this.props.location.pathname.split('/').pop() === 'edit' && this.props.selectedCustomerIds.length > 0 && _.isEqual(this.state.selectedCustomerIds, [0]) && !_.isEqual(prevProps.selectedCustomerIds, this.props.selectedCustomerIds)) {
      this.setState(
        { selectedCustomerIds: [0].concat(this.props.selectedCustomerIds) },
        () => {
          this.props.fetchCustomers(1, { 'q[id_not_in]': this.state.selectedCustomerIds });
        }
      );
    }

    // Si el nombre del grupo viene por props igualarlo
    if (this.state.name === '' && this.props.name && prevProps.name !== this.props.name) {
      this.setState({ name: this.props.name });
    }
  }

  changeTab = (tab) => {
    this.setState({
      tabSelected: tab
    });
  }

  onSearchChange = (e) => {
    const { value } = e.target;

    this.setState(
      { customersSearch: value },
      () => {
        this.props.fetchCustomers(1, {
          'q[id_not_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.customersSearch || 'none',
          'q[customer_tags_tag_id_in_all]': this.state.customersTags.length > 0 ? this.state.customersTags : 'none'
        });
      }
    );
  }

  onSearchSelectedCustomersChange = (e) => {
    const { value } = e.target;

    this.setState(
      { selectedCustomersSearch: value },
      this.props.fetchSelectedCustomers(1, {
        'q[id_in]': this.state.selectedCustomerIds,
        'q[name_phone_email_cont]': value || 'none',
        'q[customer_tags_tag_id_in_all]': this.state.selectedCustomersTags.length > 0 ? this.state.selectedCustomersTags : 'none'
      })
    );
  }

  onCustomersTagsChange = (options) => {
    const value = options === null ? [] : options.map((opt) => opt.value);

    this.setState(
      { customersTags: value },
      () => {
        this.props.fetchCustomers(1, {
          'q[id_not_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.customersSearch || 'none',
          'q[customer_tags_tag_id_in_all]': value || 'none'
        });
      }
    );
  }

  onSelectedCustomersTagsChange = (options) => {
    const value = options === null ? [] : options.map((opt) => opt.value);

    this.setState(
      { selectedCustomersTags: value },
      () => {
        this.props.fetchSelectedCustomers(1, {
          'q[id_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.selectedCustomersSearch || 'none',
          'q[customer_tags_tag_id_in_all]': value || 'none'
        });
      }
    );
  }

  changeCustomersPage = (page) => {
    this.setState(
      { currentCustomersPage: page.selected },
      () => {
        this.props.fetchCustomers(
          this.state.currentCustomersPage + 1,
          {
            'q[id_not_in]': this.state.selectedCustomerIds,
            'q[name_phone_email_cont]': this.state.customersSearch || 'none',
            'q[customer_tags_tag_id_in_all]': this.state.customersTags.length > 0 ? this.state.customersTags : 'none'
          }
        );
      }
    );
  }

  changeSelectedCustomersPage = (page) => {
    this.setState(
      { currentSelectedCustomersPage: page.selected },
      () => {
        this.props.fetchSelectedCustomers(
          this.state.currentSelectedCustomersPage + 1,
          {
            'q[id_in]': this.state.selectedCustomerIds,
            'q[name_phone_email_cont]': this.state.selectedCustomersSearch || 'none',
            'q[customer_tags_tag_id_in_all]': this.state.selectedCustomersTags.length > 0 ? this.state.selectedCustomersTags : 'none'
          }
        );
      }
    );
  }

  onChangeCustomerCheckbox = (e) => {
    const el = e.target;

    if (el.checked) {
      this.setState((prevState) => ({
        checkedCustomerIds: prevState.checkedCustomerIds.concat(el.value)
      }));
    } else {
      const index = this.state.checkedCustomerIds.indexOf(el.value);

      if (index > -1) {
        this.setState((prevState) => ({
          checkedCustomerIds: prevState.checkedCustomerIds.splice(index, 0)
        }));
      }
    }
  }

  onChangeSelectedCustomerCheckbox = (e) => {
    const el = e.target;

    if (el.checked) {
      this.setState((prevState) => ({
        checkedSelectedCustomerIds: prevState.checkedSelectedCustomerIds.concat(el.value)
      }));
    } else {
      const index = this.state.checkedSelectedCustomerIds.indexOf(el.value);

      if (index > -1) {
        this.setState((prevState) => ({
          checkedSelectedCustomerIds: prevState.checkedSelectedCustomerIds.splice(index, 0)
        }));
      }
    }
  }

  selectCustomers = (e) => {
    e.preventDefault();

    this.setState((prevState) => ({
      selectedCustomerIds: prevState.selectedCustomerIds.concat(prevState.checkedCustomerIds),
      checkedCustomerIds: []
    }), () => {
      document.getElementById('selectAll--customers').checked = false;
      this.props.fetchCustomers(
        this.state.currentCustomersPage + 1,
        {
          'q[id_not_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.customersSearch || 'none',
          'q[customer_tags_tag_id_in_all]': this.state.customersTags.length > 0 ? this.state.customersTags : 'none'
        }
      );
      this.props.fetchSelectedCustomers(
        this.state.currentSelectedCustomersPage + 1,
        {
          'q[id_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.selectedCustomersSearch || 'none',
          'q[customer_tags_tag_id_in_all]': this.state.selectedCustomersTags.length > 0 ? this.state.selectedCustomersTags : 'none'
        }
      );
    });
  }

  unselectCustomers = (e) => {
    e.preventDefault();

    this.setState(
      (prevState) => {
        let selectedCustomerIds = prevState.selectedCustomerIds.filter((el) => !prevState.checkedSelectedCustomerIds.includes(el));
        if (_.isEqual(selectedCustomerIds, [])) selectedCustomerIds = [0];
        return { selectedCustomerIds, checkedSelectedCustomerIds: [] };
      },
      () => {
        document.getElementById('selectAll--selected_customers').checked = false;
        this.props.fetchCustomers(this.state.currentCustomersPage + 1, {
          'q[id_not_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.customersSearch || 'none'
        });
        this.props.fetchSelectedCustomers(this.state.currentSelectedCustomersPage + 1, {
          'q[id_in]': this.state.selectedCustomerIds,
          'q[name_phone_email_cont]': this.state.selectedCustomersSearch || 'none'
        });
      }
    );
  }

  selectAll = (e) => {
    const { checked } = e.target;

    if (checked) {
      if (this.state.tabSelected === 'customers') {
        document.querySelectorAll('#customers input[type="checkbox"]').forEach((el) => {
          el.click();
        });
      } else {
        document.querySelectorAll('#selected_customers input[type="checkbox"]').forEach((el) => {
          el.click();
        });
      }
    } else if (this.state.tabSelected === 'customers') {
      document.querySelectorAll('#customers input[type="checkbox"]').forEach((el) => {
        el.click();
      });
    } else {
      document.querySelectorAll('#selected_customers input[type="checkbox"]').forEach((el) => {
        el.click();
      });
    }
  }

  submitContactGroup = () => {
    const { name, selectedCustomerIds } = this.state;
    selectedCustomerIds.shift();

    if (this.props.location.pathname.split('/').pop() === 'edit') {
      this.props.updateContactGroup(
        id,
        {
          contact_group: {
            name,
            customer_ids: selectedCustomerIds
          }
        },
        csrfToken
      );
    } else {
      this.props.createContactGroup(
        {
          contact_group: {
            name,
            customer_ids: selectedCustomerIds
          }
        },
        csrfToken
      );
    }
  }

  onChange = (e) => {
    const el = e.target;
    this.setState({
      [el.name]: el.value
    });
  }

  render() {
    return (
      <div className="box">
        <div className="card-box mb-16">
          <div className="row">
            <div className="col-xs-12 mb-12">
              <label htmlFor="name">Nombre del grupo</label>
              <input id="name" type="text" name="name" className="input" value={this.state.name} onChange={this.onChange} />
              <i className="validation-msg capitalize">{this.props.nameValidationText}</i>
            </div>
          </div>
        </div>
        <div className="card-box mb-16">
          <div className="row">
            <div className="col-xs-12">
              <div className="mb-8">
                <i className="validation-msg">{this.state.selectedCustomerIds.length > 0 ? '' : this.props.customersValidationText}</i>
              </div>
            </div>
            <TabSelector
              tabSelected={this.state.tabSelected}
              changeTab={this.changeTab}
            />
            <CustomersTabContent
              selectAll={this.selectAll}
              customersSearch={this.state.customersSearch}
              onSearchChange={this.onSearchChange}
              onChangeCustomerCheckbox={this.onChangeCustomerCheckbox}
              onCustomersTagsChange={this.onCustomersTagsChange}
              customers={this.props.customers}
              tabSelected={this.state.tabSelected}
              selectCustomers={this.selectCustomers}
              totalPages={this.props.totalPages}
              tags={this.props.tags}
              changeCustomersPage={this.changeCustomersPage}
              currentCustomersPage={this.state.currentCustomersPage}
            />
            <SelectedCustomersTabContent
              selectAll={this.selectAll}
              selectedCustomers={this.props.selectedCustomers}
              customersSearch={this.state.selectedCustomersSearch}
              onSearchSelectedCustomersChange={this.onSearchSelectedCustomersChange}
              onSelectedCustomersTagsChange={this.onSelectedCustomersTagsChange}
              onChangeSelectedCustomerCheckbox={this.onChangeSelectedCustomerCheckbox}
              tabSelected={this.state.tabSelected}
              unselectCustomers={this.unselectCustomers}
              totalPages={this.props.totalSelectedCustomersPages}
              tags={this.props.tags}
              changeSelectedCustomersPage={this.changeSelectedCustomersPage}
              currentSelectedCustomersPage={this.state.currentSelectedCustomersPage}
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-12">
            <div className="my-16 t-right hide-on-xs">
              <a className="cancel-link mr-30" href={ `/retailers/${ENV.SLUG}/contact_groups` }>Cancelar</a>
              <input
                type="submit"
                name="commit"
                className="btn-btn btn-submit btn-primary-style"
                value="Guardar"
                onClick={this.submitContactGroup}
              />
            </div>
            <div className="hide-on-xs-and-up t-center my-16">
              <div>
                <input
                  type="submit"
                  name="commit"
                  className="btn-btn btn-submit btn-primary-style"
                  value="Guardar"
                  onClick={this.submitContactGroup}
                />
              </div>
              <div className="mt-20">
                <a className="cancel-link" href={ `/retailers/${ENV.SLUG}/contact_groups` }>Cancelar</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    name: state.contactGroupName || '',
    customers: state.customers || [],
    totalPages: state.total_customers || 0,
    selectedCustomers: state.selectedCustomers || [],
    selectedCustomerIds: state.selectedCustomerIds || [],
    totalSelectedCustomersPages: state.totalSelectedCustomersPages || 0,
    tags: state.tags || [],
    nameValidationText: state.nameValidationText,
    customersValidationText: state.customersValidationText
  };
}

function mapDispatchToProps(dispatch) {
  return {
    fetchCustomers: (page = 1, params = null) => {
      dispatch(fetchCustomers(page, params));
    },
    fetchSelectedCustomers: (page = 1, params = null) => {
      dispatch(fetchSelectedCustomers(page, params));
    },
    fetchDefaultSelectedCustomers: (id, page = 1, params = null) => {
      dispatch(fetchDefaultSelectedCustomers(id, page, params));
    },
    fetchTags: () => {
      dispatch(fetchTags());
    },
    createContactGroup: (contactGroup, token) => {
      dispatch(createContactGroup(contactGroup, token));
    },
    updateContactGroup: (id, contactGroup, token) => {
      dispatch(updateContactGroup(id, contactGroup, token));
    }
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withRouter(ContactGroup));
