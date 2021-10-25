require 'csv'
require 'roo'

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

    def csv_import(retailer_user, file)
      # Stores all errors
      @errors = { errors: [] }

      final_file = parsed_file(file)

      if final_file
        import_logger = ImportContactsLogger.create(
          retailer_user_id: retailer_user.id,
          retailer_id: retailer_user.retailer.id,
          original_file_name: file&.original_filename,
          file: file
        )

        return error_response(['No fue posible cargar el archivo enviado']) unless import_logger.file.attached?

        Customers::ImportCustomersJob.perform_later(import_logger.id, retailer_user.id)
        { body: nil, status: :ok }
      else
        error_response(@errors[:errors])
      end
    end

    private

      def parsed_file(file)
        file_type = file.content_type
        return unless right_file_type?(file_type)

        data = if file_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                 xlsx = Roo::Spreadsheet.open(file)
                 xlsx.to_csv
               else
                 file.read
               end

        data = data.gsub(';', ',')

        options = {
          headers: true,
          encoding: 'UTF-8',
          col_sep: ',',
          skip_blanks: true, # skips blank lines
          skip_lines: /^(?:,\s*)+$/ # skips lines with all empty spaces
        }

        file_data = CSV.parse(data, options)

        if file_data.empty?
          @errors[:errors] << ['El archivo está vacío']
          return
        end

        file_headers = file_data.headers.compact.map(&:strip)
        return unless right_headers?(file_headers)

        file_data
      end

      def type_error_message
        ['Tipo de archivo inválido. Debe ser CSV (.csv) o Excel (.xlsx)']
      end

      def error_response(messages)
        { body: { errors: messages }, status: :unprocessable_entity }
      end

      def permited_headers
        CSV_ATTRIBUTES.keys.map(&:to_s)
      end

      def right_file_type?(file_type)
        unless ['text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'].include?(file_type)
          @errors[:errors] << type_error_message
          return false
        end

        true
      end

      def right_headers?(file_headers)
        return true if file_headers.empty?

        if (permited_headers - file_headers).any?
          @errors[:errors] << ['Las columnas del archivo no coinciden. Arregle su archivo y pruebe de nuevo']
          return false
        end

        true
      end
  end
end
