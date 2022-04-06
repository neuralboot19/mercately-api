require 'rails_helper'

RSpec.describe 'Api::V1::AutomaticAnswersController', type: :request do
  describe '#save_automatic_answer' do
    context 'when the retailer does not have whatsapp integrated' do
      let(:retailer_user) { create(:retailer_user, :with_retailer) }

      it 'does not create or update an automatic answer' do
        automatic_answer = {
          whatsapp: true,
          message_type: 'inactive_customer',
          status: 'active',
          interval: 12,
          message: 'Algún otro texto de prueba.'
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(0)
      end
    end

    context 'when the retailer does not have messenger integrated' do
      let(:retailer_user) { create(:retailer_user, :with_retailer) }

      before do
        sign_in retailer_user
      end

      it 'does not create or update an automatic answer' do
        automatic_answer = {
          messenger: true,
          message_type: 'inactive_customer',
          interval: 12,
          message: 'Algún otro texto de prueba.',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(0)
      end
    end

    context 'when the retailer does not have instagram integrated' do
      let(:retailer_user) { create(:retailer_user, :with_retailer) }

      before do
        sign_in retailer_user
      end

      it 'does not create or update an automatic answer' do
        automatic_answer = {
          instagram: true,
          message_type: 'inactive_customer',
          interval: 12,
          message: 'Test message',
          always_active: true,
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(0)
      end
    end

    context 'when the retailer does not have neither whatsapp or messenger integrated' do
      let(:retailer_user) { create(:retailer_user, :with_retailer) }

      before do
        sign_in retailer_user
      end

      it 'does not create or update an automatic answer' do
        automatic_answer = {
          whatsapp: true,
          message_type: 'inactive_customer',
          interval: 12,
          message: 'Algún otro texto de prueba.',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(0)
      end
    end

    context 'when some field is empty' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }

      before do
        sign_in retailer_user
      end

      it 'does not create or update an automatic answer' do
        automatic_answer = {
          whatsapp: true,
          message_type: 'inactive_customer',
          interval: 12,
          message: '',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(0)
      end
    end

    context 'when the retailer has whatsapp integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }

      before do
        sign_in retailer_user
      end

      it 'creates or updates an automatic answer' do
        automatic_answer = {
          whatsapp: true,
          message_type: 'inactive_customer',
          interval: 12,
          message: 'Algún otro texto de prueba.',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(1)
      end
    end

    context 'when the retailer has messenger integrated' do
      let(:facebook_retailer) { create(:facebook_retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: facebook_retailer.retailer) }

      before do
        sign_in retailer_user
      end

      it 'creates or updates an automatic answer' do
        automatic_answer = {
          messenger: true,
          message_type: 'inactive_customer',
          status: 'active',
          interval: 12,
          message: 'Algún otro texto de prueba.',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(1)
      end
    end

    context 'when the retailer has instagram integrated' do
      let(:facebook_retailer) { create(:facebook_retailer, instagram_integrated: true) }
      let(:retailer_user) { create(:retailer_user, retailer: facebook_retailer.retailer) }

      before do
        sign_in retailer_user
      end

      it 'creates or updates an automatic answer' do
        automatic_answer = {
          instagram: true,
          message_type: 'inactive_customer',
          status: 'active',
          interval: 12,
          message: 'Test message',
          always_active: true
        }

        expect {
          post '/api/v1/automatic_answers', params: { slug: retailer_user.retailer.slug, automatic_answer: automatic_answer }
        }.to change { AutomaticAnswer.count }.by(1)
      end
    end
  end
end