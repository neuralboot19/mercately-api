require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe ContactGroups::ImportJob, type: :job do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  describe '#perform' do
    context 'when there are duplicated phones in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
        end.to change(Customer, :count).by(0)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Este tel')
        expect(mail.body.encoded).to include('duplicado')
      end
    end

    context 'when there are duplicated emails in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
        end.to change(Customer, :count).by(0)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Este email')
        expect(mail.body.encoded).to include('duplicado')
      end
    end

    context 'when there are wrong formatted emails in the file' do
      it 'does not import the row' do
        copy_file('spec/fixtures/duplicated_data_in_customers.csv')

        expect do
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
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
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
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
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
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
          ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
            'text/csv', 'Test contact group')
        end.to change(Customer, :count).by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([retailer_user.email])
        expect(mail.body.encoded).to include('Ya tienes un cliente registrado con este n')
      end
    end

    context 'when the row is filled well in the file' do
      context 'when the contact group does not exist yet' do
        context 'when it is a csv file' do
          it 'imports the row and creates the contact group' do
            copy_file('spec/fixtures/customers.csv')

            expect(retailer.contact_groups.count).to eq(0)
            expect do
              ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
                'text/csv', 'Test contact group')
            end.to change(Customer, :count).by(2)

            mail = ActionMailer::Base.deliveries.last
            expect(mail.to).to eq([retailer_user.email])
            expect(retailer.contact_groups.count).to eq(1)
          end
        end

        context 'when it is an excel file' do
          it 'imports the row and creates the contact group' do
            copy_file('spec/fixtures/customers.xlsx', 'xlsx')

            expect(retailer.contact_groups.count).to eq(0)
            expect do
              ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.xlsx", retailer_user.id,
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'Test contact group')
            end.to change(Customer, :count).by(2)

            mail = ActionMailer::Base.deliveries.last
            expect(mail.to).to eq([retailer_user.email])
            expect(retailer.contact_groups.count).to eq(1)
          end
        end
      end

      context 'when the contact group already exists' do
        let!(:contact_group) { create(:contact_group, :with_customers, retailer: retailer) }

        it 'imports the row and updates the current contact group' do
          copy_file('spec/fixtures/customers.xlsx', 'xlsx')

          expect(retailer.contact_groups.count).to eq(1)
          expect(contact_group.customers.count).to eq(3)
          expect do
            ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.xlsx", retailer_user.id,
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', contact_group.name,
              contact_group.id)
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])
          expect(retailer.contact_groups.count).to eq(1)
          expect(contact_group.customers.count).to eq(5)
        end
      end

      context 'when there are custom fields in the file' do
        let!(:customer_related_field) do
          create(:customer_related_field, retailer: retailer, name: 'Nombre completo', field_type: 'string')
        end

        it 'imports the row and saves the custom fields' do
          copy_file('spec/fixtures/custom_fields.csv')

          expect do
            ContactGroups::ImportJob.perform_now("import-file-#{retailer_user.id}.csv", retailer_user.id,
              'text/csv', 'Test contact group')
          end.to change(Customer, :count).by(2)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq([retailer_user.email])

          expect(Customer.last.customer_related_data.find_by(customer_related_field_id: customer_related_field.id))
            .not_to be_nil
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
