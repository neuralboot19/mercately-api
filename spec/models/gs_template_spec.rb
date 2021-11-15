require 'rails_helper'

RSpec.describe GsTemplate, type: :model do
  subject { build(:gs_template, retailer: retailer) }
  let(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }
  let(:retailer) { retailer_user.retailer }

  let(:submit_response_rejected) do
    {
      'status': 'success',
      'template': {
        'category': 'TICKET_UPDATE',
        'createdOn': 1607593307541,
        'data': 'your ticket has been confirmed for {{1}} persons on date {{2}}.',
        'elementName': 'ticket_check_url_334',
        'id': '7423a738-5193-4cc2-9254-100ee002f98c',
        'languageCode': 'en_US',
        'languagePolicy': 'deterministic',
        'master': true,
        'meta': '{\'example\':\'your ticket has been confirmed for 4 persons on date 2020-05-04.\'}',
        'modifiedOn': 1607593307934,
        'status': 'REJECTED',
        'templateType': 'TEXT',
        'vertical': 'BUTTON_CHECK'
      }
    }
  end

  let(:submit_response_approved) do
    {
      'status': 'success',
      'template': {
        'category': 'TICKET_UPDATE',
        'createdOn': 1607593307541,
        'data': 'your ticket has been confirmed for {{1}} persons on date {{2}}.',
        'elementName': 'ticket_check_url_334',
        'id': '7423a738-5193-4cc2-9254-100ee002f98c',
        'languageCode': 'en_US',
        'languagePolicy': 'deterministic',
        'master': true,
        'meta': '{\'example\':\'your ticket has been confirmed for 4 persons on date 2020-05-04.\'}',
        'modifiedOn': 1607593307934,
        'status': 'APPROVED',
        'templateType': 'TEXT',
        'vertical': 'BUTTON_CHECK'
      }
    }
  end

  let(:submit_response_pending) do
    {
      'status': 'success',
      'template': {
        'category': 'TICKET_UPDATE',
        'createdOn': 1607593307541,
        'data': 'your ticket has been confirmed for {{1}} persons on date {{2}}.',
        'elementName': 'ticket_check_url_334',
        'id': '7423a738-5193-4cc2-9254-100ee002f98c',
        'languageCode': 'en_US',
        'languagePolicy': 'deterministic',
        'master': true,
        'meta': '{\'example\':\'your ticket has been confirmed for 4 persons on date 2020-05-04.\'}',
        'modifiedOn': 1607593307934,
        'status': 'PENDING',
        'templateType': 'TEXT',
        'vertical': 'BUTTON_CHECK'
      }
    }
  end

  let(:templates_list) do
    {
      'status': 'success',
      'templates': [
        {
          'category': 'ALERT_UPDATE',
          'createdOn': 1618846866495,
          'data': '{{1}} is currently unavailable due to *{{2}}*.\r\n\r\nHola. Saludos.',
          'elementName': 'common_service_2',
          'id': '05c23eb1-3381-4350-a140-4519918bb15b',
          'languageCode': 'en_US',
          'languagePolicy': 'deterministic',
          'master': false,
          'meta': '{\'example\':\'[SMS service] is currently unavailable due to *[Central government guideline]*.' \
            '\\r\\n\\r\\nHola. Saludos.\'}',
          'modifiedOn': 1625392806426,
          'status': 'APPROVED',
          'templateType': 'TEXT',
          'vertical': 'SERVICE UPDATE'
        },
        {
          'category': 'ACCOUNT_UPDATE',
          'createdOn': 1600987654773,
          'data': 'Hola, claro con mucho gusto, en Riberas de la Bahía estamos para servirte. Soy Jorge Rodríguez, ' \
            'ayúdame con tu nombre por favor.',
          'elementName': 'nombre_cliente',
          'id': '05fff973-c647-49ed-844e-46341e9d354a',
          'languageCode': 'es',
          'languagePolicy': 'deterministic',
          'master': true,
          'meta': '{\'example\':\'Hola, claro con mucho gusto, en Riberas de la Bahía estamos para servirte. ' \
            'Soy Jorge Rodríguez, ayúdame con tu nombre por favor.\'}',
          'modifiedOn': 1625392806426,
          'status': 'REJECTED',
          'templateType': 'TEXT',
          'vertical': 'nombre_cliente'
        }
      ]
    }.with_indifferent_access
  end

  let(:submit_response_error) do
    {
      'status': 'error',
      'message': 'Template Not Supported On Gupshup Platform'
    }
  end

  describe '#format_label' do
    before do
      allow(Connection).to receive(:prepare_connection).and_return(true)
      allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
        submit_response_pending.to_json))
    end

    it 'formats the label field before saving' do
      subject.label = 'Example label'
      expect(subject.save).to be true
      expect(subject.label).to eq 'example_label'
    end
  end

  describe '#vars_repeated?' do
    before do
      allow(Connection).to receive(:prepare_connection).and_return(true)
      allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
        submit_response_pending.to_json))
    end

    context 'when there are repeated vars' do
      it 'does not save the template' do
        subject.text = 'My Text with var {{1}}, {{1}}'
        expect(subject.save).to be false
      end
    end

    context 'when there are not repeated vars' do
      it 'saves the template' do
        subject.text = 'My Text with var {{1}}, {{2}}'
        expect(subject.save).to be true
      end
    end
  end

  describe '#submit_template' do
    let(:retailer) { create(:retailer, gupshup_app_id: '12345', gupshup_app_token: '12345') }

    context 'when the gs template is not on status pending' do
      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'accepted') }

      it 'does not submit it' do
        expect(gs_template.submit_template).to be_nil
      end
    end

    context 'when the gs template already has a ws template id' do
      let(:gs_template) do
        create(:gs_template, retailer: retailer, status: 'pending',
          ws_template_id: '7423a738-5193-4cc2-9254-100ee002f98c')
      end

      it 'does not submit it' do
        expect(gs_template.submit_template).to be_nil
      end
    end

    context 'when the gs template is submitted with status pending' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
          submit_response_pending.to_json))
      end

      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'pending') }

      it 'updates the status to submitted' do
        gs_template.submit_template

        expect(gs_template.status).to eq('submitted')
        expect(gs_template.ws_template_id).to eq('7423a738-5193-4cc2-9254-100ee002f98c')
      end
    end

    context 'when the gs template is submitted with status rejected' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
          submit_response_rejected.to_json))
      end

      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'pending') }

      it 'updates the status to rejected' do
        gs_template.submit_template

        expect(gs_template.status).to eq('rejected')
        expect(gs_template.ws_template_id).to eq('7423a738-5193-4cc2-9254-100ee002f98c')
      end
    end

    context 'when the gs template is submitted with status approved' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
          submit_response_approved.to_json))
      end

      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'pending') }

      it 'updates the status to accepted' do
        gs_template.submit_template

        expect(gs_template.status).to eq('accepted')
        expect(gs_template.ws_template_id).to eq('7423a738-5193-4cc2-9254-100ee002f98c')
      end
    end

    context 'when the gs template is submitted with status pending and return an error' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
          submit_response_error.to_json))
      end

      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'pending') }

      it 'does not update status and ws_templated_id' do
        gs_template.submit_template

        expect(gs_template.status).to eq('pending')
        expect(gs_template.ws_template_id).to be_nil
      end
    end
  end

  describe '#accept_template' do
    let(:retailer) { create(:retailer, gupshup_app_id: '12345', gupshup_app_token: '12345') }

    context 'when the gs template is not on status submitted' do
      let(:gs_template) { create(:gs_template, retailer: retailer, status: 'accepted') }

      it 'does not accept it' do
        expect(gs_template.accept_template).to be_nil
      end
    end

    context 'when the gs template is accepted' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:get_request).and_return(templates_list)
      end

      context 'when the gs template was approved by GupShup' do
        context 'when the gs template does not have ws_template id' do
          let(:gs_template) do
            create(:gs_template, retailer: retailer, status: 'submitted', label: 'common_service_2')
          end

          it 'updates the status to accepted by label' do
            expect { gs_template.accept_template }.to change(WhatsappTemplate, :count).by(1)

            expect(gs_template.status).to eq('accepted')

            last_ws_template = WhatsappTemplate.last
            expect(last_ws_template.gupshup_template_id).to eq('05c23eb1-3381-4350-a140-4519918bb15b')
            expect(last_ws_template.text.scan(/(?<!\\)\*/).size).to eq(2)
            expect(last_ws_template.text.scan(/\\\*/).size).to eq(2)
            expect(last_ws_template.text.scan(/\\n/).size).to eq(2)
          end
        end

        context 'when the gs template has ws_template id' do
          let(:gs_template) do
            create(:gs_template, retailer: retailer, status: 'submitted',
              ws_template_id: '05c23eb1-3381-4350-a140-4519918bb15b')
          end

          it 'updates the status to accepted by ws template id' do
            expect { gs_template.accept_template }.to change(WhatsappTemplate, :count).by(1)

            expect(gs_template.status).to eq('accepted')

            last_ws_template = WhatsappTemplate.last
            expect(last_ws_template.gupshup_template_id).to eq('05c23eb1-3381-4350-a140-4519918bb15b')
            expect(last_ws_template.text.scan(/(?<!\\)\*/).size).to eq(2)
            expect(last_ws_template.text.scan(/\\\*/).size).to eq(2)
            expect(last_ws_template.text.scan(/\\n/).size).to eq(2)
          end
        end
      end

      context 'when the gs template was rejected by GupShup' do
        let(:gs_template) do
          create(:gs_template, retailer: retailer, status: 'submitted',
            ws_template_id: '05fff973-c647-49ed-844e-46341e9d354a')
        end

        it 'updates the status to rejected' do
          expect { gs_template.accept_template }.to change(WhatsappTemplate, :count).by(0)

          expect(gs_template.status).to eq('rejected')
        end
      end
    end
  end
end
