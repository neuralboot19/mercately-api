require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe Customers::ImportCustomersJob, type: :job do
  let(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }

  describe '#perform' do
    context 'when there are duplicated phones in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(0)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Este tel')
        expect(mail.body.encoded).to include('duplicado en su archivo')
      end
    end

    context 'when there are duplicated emails in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(0)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Este email')
        expect(mail.body.encoded).to include('duplicado en su archivo')
      end
    end

    context 'when there are wrong formatted emails in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(0)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Error en el formato del email')
      end
    end

    context 'when there are wrong formatted phones in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/invalid_data_customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(2)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Error en el formato de tel')
      end
    end

    context 'when there are rows without phone and email in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/invalid_data_customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(2)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('No tiene email ni tel')
      end
    end

    context 'when occurs an error saving the customer' do
      let!(:customer) { create(:customer, retailer: retailer_user.retailer, phone: '59355555555', country_id: nil) }

      it 'does not import the row' do
        copy_file('spec/fixtures/customers.csv')

        expect do
          Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv')
        end.to change(Customer, :count).by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Ya tienes un cliente registrado con este n')
      end
    end

    context 'when the row is filled well in the file' do
      context 'when it is a csv file' do
        it 'imports the row' do
          copy_file('spec/fixtures/customers.csv')

          expect do
            Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
              'text/csv')
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
        end
      end

      context 'when it is an excel file' do
        it 'imports the row' do
          copy_file('spec/fixtures/customers.xlsx', 'xlsx')

          expect do
            Customers::ImportCustomersJob.perform_now("import-file-#{retailer_user.id}.xlsx", retailer_user.id,
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
        end
      end
    end
  end

  def copy_file(file_name, extension = 'csv')
    File.open(Rails.root.join('public', "import-file-#{retailer_user.id}.#{extension}"), 'wb') do |f|
      File.open(Rails.root + file_name, 'r') do |fb|
        while (line = fb.gets)
          f.write(line)
        end
      end
    end
  end
end
