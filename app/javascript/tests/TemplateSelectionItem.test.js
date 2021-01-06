import React from 'react';
import { shallow } from 'enzyme';
import TemplateSelectionItem from '../components/WhatsApp/TemplateSelectionItem';

describe('tests over <TemplateSelectionItem/>', () => {
  const setTemplateType = jest.fn();
  const getCleanTemplate = jest.fn();
  const selectTemplate = jest.fn();
  const template = {
    id: 90,
    retailer_id: 241,
    text: "Your * number * has been *.",
    status: "active",
    created_at: "2020-12-03T22:15:59.645Z",
    updated_at: "2020-12-03T22:21:28.093Z",
    template_type: "text",
    gupshup_template_id: "255935d2-5707-4bfd-8185-ac4a55bdf621"
  };

  it('should render on desktop', () => {
    expect.hasAssertions();
    const wrapper = shallow(
      <TemplateSelectionItem
        template={template}
        onMobile={false}
        setTemplateType={setTemplateType}
        getCleanTemplate={getCleanTemplate}
        selectTemplate={selectTemplate}
      />
    );
    expect(wrapper).toMatchSnapshot();
  });

  it('should render on mobile', () => {
    expect.hasAssertions();
    const wrapper = shallow(
      <TemplateSelectionItem
        template={template}
        onMobile
        setTemplateType={setTemplateType}
        getCleanTemplate={getCleanTemplate}
        selectTemplate={selectTemplate}
      />
    );
    expect(wrapper).toMatchSnapshot();
  });
});
