module CustomFieldsHelper
  def custom_field_type(form_object, customer_related_field)
    case customer_related_field.field_type
    when 'string'
      form_object.text_field :data, class: 'input'
    when 'integer', 'float'
      form_object.number_field :data, class: 'input', onkeypress: 'onlyNumber(event)'
    when 'boolean'
      content_tag :div do
        [
          form_object.radio_button(:data, true, checked: true),
          form_object.label(:data_true, 'Verdadero'),
          form_object.radio_button(:data, false),
          form_object.label(:data_false, 'Falso')
        ].join.html_safe
      end
    when 'date'
      form_object.date_field :data, class: 'input', value: form_object.object&.data
    when 'list'
      form_object.select :data, options_for_select(customer_related_field.list_options.map { |l| [l.value, l.key] },
        form_object.object&.data), class: 'input', multiple: true, include_blank: true
    end
  end
end
