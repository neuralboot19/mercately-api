require 'csv'

module ImportCustomersConcern
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    CSV_ATTRIBUTES = {
      'First Name': :first_name,
      'Last Name': :last_name,
      'Email': :email,
      'Phone': :phone
    }.with_indifferent_access

    def csv_import!(retailer, file)
      # Stores all errors
      @errors = { errors: [] }

      # Stores all phones and emails in the csv file, this helps
      # to handle with row duplication
      @phones_in_csv = {}.with_indifferent_access
      @emails_in_csv = {}.with_indifferent_access

      rows = parse_file(retailer, file)
      return error_response(@errors[:errors]) if @errors[:errors].any?
      return error_response(['El archivo CSV está vacío']) unless rows.any?

      Customer.transaction do
        rows.each_with_index do |row|
          phone = row[:phone]&.strip
          email = row[:email]&.strip

          customer = retailer.customers.find_by(phone: phone) if phone.present?
          customer ||= retailer.customers.find_by(email: email) if email.present?
          customer ||= Customer.new

          customer.assign_attributes(row.except(:row_number))
          customer.save!
        rescue => e
          @errors[:errors] << error_message(row[:row_number], e.message)
          return error_response(@errors[:errors])
        end
      end

      { body: nil, status: :ok }
    end

    private

    def parse_file(retailer, file)
      parsed_file(file).map.with_index do |row, index|
        # Replace all headers with the actual field name
        row.to_h.keys.each do |k|
          if CSV_ATTRIBUTES[k].present?
            value = row.delete(k)[1]
            row[CSV_ATTRIBUTES[k]] = value
          end
        end

        phone = row[:phone]&.gsub(' ', '')
        email = row[:email]&.gsub(' ', '')

        duplicated?(index, phone, email)
        email_phone_valid?(index, phone, email)

        @phones_in_csv.merge!("#{phone}": true) if phone.present?
        @emails_in_csv.merge!("#{email}": true) if email.present?

        row = row.to_h.with_indifferent_access

        row['row_number'] = index
        row['retailer_id'] = retailer.id
        row['valid_customer'] = true
        row
      end
    end

    def duplicated?(index, phone, email)
      if @phones_in_csv[phone].present?
        @errors[:errors] << error_message(index, "Este teléfono #{phone} está duplicado en su archivo")
        return true
      end

      if @emails_in_csv[email].present?
        @errors[:errors] << error_message(index, "Este email #{email} está duplicado en su archivo")
        return true
      end

      false
    end

    def parsed_file(file)
      file_type = file.content_type
      return [] unless right_file_type?(file_type)

      data = file.read

      options = {
        headers: true,
        encoding: 'UTF-8',
        col_sep: ',',
        skip_blanks: true, # skips blank lines
        skip_lines: /^(?:,\s*)+$/ # skips lines with all empty spaces
      }

      file_data = CSV.parse(data, options)

      file_headers = file_data.headers
      return [] unless right_headers?(file_headers)

      file_data
    end

    def type_error_message
      [
        'El archivo que subiste no era un CSV. ' \
        'Vuelva a intentarlo subiendo el archivo correcto.'
      ]
    end

    def error_message(row_number, message)
      "Fila #{row_number + 1} inválida: #{message}"
    end

    def error_response(messages)
      { body: { errors: messages }, status: :unprocessable_entity }
    end

    def permited_headers
      CSV_ATTRIBUTES.keys.map(&:to_s)
    end

    def right_file_type?(file_type)
      if file_type != 'text/csv'
        @errors[:errors] << type_error_message
        return false
      end

      true
    end

    def right_headers?(file_headers)
      return true if file_headers.empty?

      if (permited_headers - file_headers).any?
        @errors[:errors] << ['Las columnas del archivo no coinciden, arregle su archivo CSV y pruebe de nuevo']
        return false
      end

      true
    end

    def email_phone_valid?(index, phone, email)
      if email.blank? && phone.blank?
        @errors[:errors] << error_message(index, 'No tiene email ni teléfono')
        return false
      end

      right_phone_format?(index, phone) if phone.present?
      right_email_format?(index, email) if email.present?
    end

    def right_phone_format?(row_number, phone)
      phone_regexp = Regexp.new('^\+[0-9]{10,13}$')
      return true if phone&.match?(phone_regexp)

      @errors[:errors] << error_message(row_number, 'Error en el formato de teléfono')
      false
    end

    def right_email_format?(row_number, email)
      email_regexp = Regexp.new('^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
      return true if email&.match?(email_regexp)

      @errors[:errors] << error_message(row_number, 'Error en el formato del email')
      false
    end
  end
end
