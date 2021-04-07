require 'csv'
require 'axlsx'

module ExportCustomersConcern
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def to_csv(customers)
      attributes = %w[first_name last_name whatsapp_name email phone id_type id_number]
      tags = customers.present? ? customers.first.retailer.tags.order(id: :asc) : {}

      CSV.generate(headers: true) do |csv|
        csv << attributes + tags.map(&:tag)

        customers.each do |customer|
          data = attributes.map { |attr| customer.send(attr) }

          tags.each do |t|
            data << (customer.tags.include?(t) ? 'X' : '')
          end

          csv << data
        end
      end
    end

    def to_excel(customers, retailer_user_id)
      attributes = %w[first_name last_name whatsapp_name email phone id_type id_number]
      tags = customers.present? ? customers.first.retailer.tags.order(id: :asc) : {}

      file = Axlsx::Package.new
      wb = file.workbook

      wb.add_worksheet do |sheet|
        sheet.add_row(attributes + tags.map(&:tag))

        customers.each do |customer|
          data = attributes.map { |attr| customer.send(attr) }

          tags.each do |t|
            data << (customer.tags.include?(t) ? 'X' : '')
          end

          sheet.add_row(data, types: :string)
        end
      end

      file.serialize Rails.root.join('public', "export-customers-#{retailer_user_id}.xlsx")
    end
  end
end
