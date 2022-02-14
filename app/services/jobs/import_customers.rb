module Jobs
  class ImportCustomers
    def save_related_data(customer, related_fields, row)
      related_fields.each do |rf|
        next unless row[rf.identifier].present? && right_format_data(rf, row[rf.identifier])

        related_data = customer.customer_related_data.find_or_initialize_by(customer_related_field_id: rf.id)

        related_data.data = if rf.field_type == 'date'
                              Time.parse(row[rf.identifier]).strftime('%Y-%m-%d')
                            else
                              row[rf.identifier]
                            end

        related_data.save
      end
    end

    def right_format_data(related_field, data)
      case related_field.field_type
      when 'integer'
        data.match?(/^[0-9]+$/)
      when 'float'
        data.match?(/^[.0-9]+$/)
      when 'boolean'
        data.match?(/^true|false$/)
      when 'date'
        right_date?(data)
      when 'list'
        keys = related_field.list_options.map(&:key)
        keys = keys.map(&:strip)

        data.strip.in?(keys)
      else
        true
      end
    end

    # Aca se evaluan los formatos de fecha. En orden son:
    # DD/MM/YYYY o DD-MM-YYYY
    # YYYY/MM/DD o YYYY-MM-DD
    # MM/DD/YYYY o MM-DD-YYYY
    def right_date?(date)
      date.match?(/^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/) ||
      date.match?(/^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$/) ||
      date.match?(/^(0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])[\/\-]\d{4}$/)
    end

    def assign_agent(customer, retailer, email)
      agent = retailer.retailer_users.find_by(email: email)
      return unless agent.present?

      assigned = AgentCustomer.find_or_create_by(customer: customer)
      assigned.retailer_user = agent
      assigned.save
    end
  end
end
