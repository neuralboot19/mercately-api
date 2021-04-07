require 'rails_helper'

RSpec.describe Customers::ExportCustomersJob, type: :job do

  describe '#perform_later' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }

    it 'enques the job' do
      ActiveJob::Base.queue_adapter = :test
      expect { Customers::ExportCustomersJob.perform_later(retailer_user.id, nil) }.to have_enqueued_job
    end
  end

  describe '#perform_now' do
    let(:retailer) { create(:retailer) }
    let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let!(:customer) { create(:customer, retailer: retailer) }

    context 'when csv format is executed' do
      it 'sends a mail with the exported customers as a file attached' do
        Customers::ExportCustomersJob.perform_now(retailer_user.id, {type: 'csv'})

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq 'Mercately Exportación de Clientes Completa'
        expect(mail.to).to eq [retailer_user.email]

        expect(mail.attachments.size).to eq 1
        attachment = mail.attachments[0]

        expect(attachment).to be_a_kind_of Mail::Part
        expect(attachment.content_type).to eq 'text/csv; charset=UTF-8'
        expect(attachment.filename).to eq 'Customers.csv'
      end
    end

    context 'when excel format is executed' do
      it 'sends a mail with the exported customers as a file attached' do
        Customers::ExportCustomersJob.perform_now(retailer_user.id, {type: 'excel'})

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq 'Mercately Exportación de Clientes Completa'
        expect(mail.to).to eq [retailer_user.email]

        expect(mail.attachments.size).to eq 1
        attachment = mail.attachments[0]

        expect(attachment).to be_a_kind_of Mail::Part
        expect(attachment.content_type).to eq(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        expect(attachment.filename).to eq 'Customers.xlsx'
      end
    end
  end
end
