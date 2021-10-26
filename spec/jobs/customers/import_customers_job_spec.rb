require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe Customers::ImportCustomersJob, type: :job do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  describe '#perform' do
    describe 'duplicated data' do
      let(:file) { File.open(Rails.root + 'spec/fixtures/duplicated_data_in_customers.csv') }

      let(:import_contacts_logger) do
        create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
      end

      before do
        allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
        allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
        allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
        import_contacts_logger.file.attach(
          io: File.open(Rails.root + 'spec/fixtures/duplicated_data_in_customers.csv'),
          filename: 'filename.csv',
          content_type: 'text/csv'
        )
      end

      context 'when there are duplicated phones in the file' do
        it 'does not import the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(0)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(mail.body.encoded).to include('Este tel')
          expect(mail.body.encoded).to include('duplicado en su archivo')
        end
      end

      context 'when there are duplicated emails in the file' do
        it 'does not import the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(0)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(mail.body.encoded).to include('Este email')
          expect(mail.body.encoded).to include('duplicado en su archivo')
        end
      end

      context 'when there are wrong formatted emails in the file' do
        it 'does not import the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(0)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(mail.body.encoded).to include('Error en el formato del email')
        end
      end
    end

    describe 'invalid data' do
      let(:file) { File.open(Rails.root + 'spec/fixtures/invalid_data_customers.csv') }

      let(:import_contacts_logger) do
        create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
      end

      before do
        allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
        allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
        allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
        import_contacts_logger.file.attach(
          io: File.open(Rails.root + 'spec/fixtures/invalid_data_customers.csv'),
          filename: 'filename.csv',
          content_type: 'text/csv'
        )
      end

      context 'when there are wrong formatted phones in the file' do
        it 'does not import the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(mail.body.encoded).to include('Error en el formato de tel')
        end
      end

      context 'when there are rows without phone and email in the file' do
        it 'does not import the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(mail.body.encoded).to include('No tiene email ni tel')
        end
      end
    end

    context 'when occurs an error saving the customer' do
      let!(:customer) { create(:customer, retailer: retailer_user.retailer, phone: '59355555555', country_id: nil) }
      let(:file) { File.open(Rails.root + 'spec/fixtures/customers.csv') }

      let(:import_contacts_logger) do
        create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
      end

      before do
        allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
        allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
        allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
        import_contacts_logger.file.attach(
          io: File.open(Rails.root + 'spec/fixtures/customers.csv'),
          filename: 'filename.csv',
          content_type: 'text/csv'
        )
      end

      it 'does not import the row' do
        expect do
          Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
        end.to change(Customer, :count).by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Ya tienes un cliente registrado con este n')
      end
    end

    context 'when the row is filled well in the file' do
      context 'when it is a csv file' do
        let(:file) { File.open(Rails.root + 'spec/fixtures/customers.csv') }

        let(:import_contacts_logger) do
          create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
        end

        before do
          allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
          allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
          allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
          import_contacts_logger.file.attach(
            io: File.open(Rails.root + 'spec/fixtures/customers.csv'),
            filename: 'filename.csv',
            content_type: 'text/csv'
          )
        end

        it 'imports the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
        end
      end

      context 'when it is an excel file' do
        let(:file) { Roo::Spreadsheet.open(Rails.root + 'spec/fixtures/customers.xlsx', extension: :xlsx) }

        let(:import_contacts_logger) do
          create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
        end

        before do
          allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
          allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
          allow(Roo::Spreadsheet).to receive(:open).and_return(file)
          import_contacts_logger.file.attach(
            io: File.open(Rails.root + 'spec/fixtures/customers.xlsx'),
            filename: 'filename.xlsx',
            content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          )
        end

        it 'imports the row' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
        end
      end

      context 'when there are custom fields in the file' do
        let!(:customer_related_field) do
          create(:customer_related_field, retailer: retailer, name: 'Nombre completo', field_type: 'string')
        end

        let(:file) { File.open(Rails.root + 'spec/fixtures/custom_fields.csv') }

        let(:import_contacts_logger) do
          create(:import_contacts_logger, retailer: retailer, retailer_user: retailer_user)
        end

        before do
          allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
          allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
          allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
          import_contacts_logger.file.attach(
            io: File.open(Rails.root + 'spec/fixtures/custom_fields.csv'),
            filename: 'filename.csv',
            content_type: 'text/csv'
          )
        end

        it 'imports the row and saves the custom fields' do
          expect do
            Customers::ImportCustomersJob.perform_now(import_contacts_logger.id, retailer_user.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])

          expect(Customer.last.customer_related_data.find_by(customer_related_field_id: customer_related_field.id))
            .not_to be_nil
        end
      end
    end
  end
end
