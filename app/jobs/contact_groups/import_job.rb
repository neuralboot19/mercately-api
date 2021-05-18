require 'csv'
require 'roo'

module ContactGroups
  class ImportJob < ApplicationJob
    queue_as :default

    CSV_ATTRIBUTES = {
      'First Name': :first_name,
      'Last Name': :last_name,
      'Email': :email,
      'Phone': :phone
    }.with_indifferent_access

    def perform(file_path, retailer_user_id, file_type, cg_name, cg_id = nil)
      retailer_user = RetailerUser.find(retailer_user_id)
      retailer = retailer_user.retailer

      # Stores all customer_ids
      @customer_ids = []

      # Stores all errors
      @errors = { errors: [] }

      # Stores all phones and emails in the csv file, this helps
      # to handle with row duplication
      @phones_in_csv = {}.with_indifferent_access
      @emails_in_csv = {}.with_indifferent_access

      # Stores lines and data that do not pass pre validations
      @data_with_errors = []

      rows = parse_file(retailer, file_path, file_type)
      File.delete(Rails.root.join('public', file_path))

      cg = if cg_id
             retailer.contact_groups.find(cg_id)
           else
             retailer.contact_groups.new(name: cg_name)
           end

      Customer.transaction do
        rows.each do |row|
          next unless valid_row?(row)

          phone = row[:phone]&.strip
          email = row[:email]&.strip
          plus_phone = phone.to_s.first == '+' ? phone : "+#{phone}"

          customer = retailer.customers.find_by(phone: plus_phone) if phone.present?
          customer ||= retailer.customers.find_by(email: email) if email.present?
          customer ||= Customer.new

          exceptions = row.keys.compact.map(&:strip) - (Customer.public_fields + %w[retailer_id valid_customer])
          exceptions += [nil]

          customer.assign_attributes(row.except(*exceptions))
          customer.from_import_file = true
          customer.save!
          @customer_ids << customer.id

          related_fields = retailer.customer_related_fields.where(identifier: exceptions)
          next unless related_fields.present?

          import_service.save_related_data(customer, related_fields, row)
        rescue => e
          @errors[:errors] << error_message(row[:row_number], e.message)
        end
      end
      cg.customer_ids = cg.customer_ids | @customer_ids
      cg.save
      if @customer_ids.present?
        RetailerMailer.imported_contact_group(retailer_user, cg, @errors[:errors]).deliver_now
      else
        cg.destroy if cg.customer_ids.blank?
        RetailerMailer.failed_import(retailer_user, @errors[:errors]).deliver_now
      end
    end

    private

      def parse_file(retailer, file_path, file_type)
        parsed_file(file_path, file_type).map.with_index do |row, index|
          # Replace all headers with the actual field name
          row.to_h.keys.compact.each do |k|
            if CSV_ATTRIBUTES[k.strip].present?
              value = row.delete(k)[1]
              row[CSV_ATTRIBUTES[k.strip]] = value
            end
          end

          phone = row[:phone]&.gsub(' ', '')
          email = row[:email]&.gsub(' ', '')

          duplicated?(index, phone, email)
          email_phone_valid?(index, phone, email)

          @phones_in_csv.merge!("#{phone}": true) if phone.present?
          @emails_in_csv.merge!("#{email}": true) if email.present?

          row = row.to_h.with_indifferent_access
          row = row.except(nil).transform_keys { |k| k.strip }

          row[:row_number] = index
          row[:retailer_id] = retailer.id
          row[:valid_customer] = true
          row[:phone] = phone
          row[:email] = email
          row
        end
      end

      def duplicated?(index, phone, email)
        if @phones_in_csv[phone].present?
          @data_with_errors << phone
          @errors[:errors] << error_message(index, "Este teléfono #{phone} está duplicado en su archivo")
          return true
        end

        if @emails_in_csv[email].present?
          @data_with_errors << email
          @errors[:errors] << error_message(index, "Este email #{email} está duplicado en su archivo")
          return true
        end

        false
      end

      def error_message(row_number, message)
        @data_with_errors << row_number
        "Fila #{row_number + 2} inválida: #{message}"
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
        phone_regexp = Regexp.new('^\+{0,1}[0-9]{10,20}$')
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

      def valid_row?(row)
        return false if @data_with_errors.include?(row[:row_number])
        return false if @data_with_errors.include?(row[:phone])
        return false if @data_with_errors.include?(row[:email])

        true
      end

      def parsed_file(file_path, file_type)
        options = {
          headers: true,
          encoding: 'UTF-8',
          col_sep: ',',
          skip_blanks: true, # skips blank lines
          skip_lines: /^(?:,\s*)+$/ # skips lines with all empty spaces
        }

        file = if file_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                 xlsx = Roo::Spreadsheet.open(Rails.root.join('public', file_path), extension: :xlsx)
                 xlsx.to_csv
               else
                 File.open(Rails.root.join('public', file_path)).read
               end

        file = file.gsub(';', ',')
        CSV.parse(file, options)
      end

      def import_service
        Jobs::ImportCustomers.new
      end
  end
end
