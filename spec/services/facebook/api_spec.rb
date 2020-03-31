require 'rails_helper'

RSpec.describe Facebook::Api do
  subject(:service_api) { described_class.new(facebook_retailer, retailer_user) }

  let(:retailer_user) { create(:retailer_user, :with_retailer, :from_fb) }
  let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer_user.retailer) }

  let(:permissions_granted) do
    {
      'data': [
        {
          'permission': 'email',
          'status': 'granted'
        },
        {
          'permission': 'catalog_management',
          'status': 'granted'
        },
        {
          'permission': 'manage_pages',
          'status': 'granted'
        },
        {
          'permission': 'pages_show_list',
          'status': 'granted'
        },
        {
          'permission': 'business_management',
          'status': 'granted'
        },
        {
          'permission': 'pages_messaging',
          'status': 'granted'
        },
        {
          'permission': 'public_profile',
          'status': 'granted'
        }
      ]
    }.with_indifferent_access
  end

  let(:permissions_msn_declined) do
    {
      'data': [
        {
          'permission': 'email',
          'status': 'granted'
        },
        {
          'permission': 'catalog_management',
          'status': 'granted'
        },
        {
          'permission': 'manage_pages',
          'status': 'declined'
        },
        {
          'permission': 'pages_show_list',
          'status': 'granted'
        },
        {
          'permission': 'business_management',
          'status': 'granted'
        },
        {
          'permission': 'pages_messaging',
          'status': 'granted'
        },
        {
          'permission': 'public_profile',
          'status': 'granted'
        }
      ]
    }.with_indifferent_access
  end

  let(:permissions_catalog_declined) do
    {
      'data': [
        {
          'permission': 'email',
          'status': 'granted'
        },
        {
          'permission': 'catalog_management',
          'status': 'declined'
        },
        {
          'permission': 'manage_pages',
          'status': 'declined'
        },
        {
          'permission': 'pages_show_list',
          'status': 'granted'
        },
        {
          'permission': 'business_management',
          'status': 'granted'
        },
        {
          'permission': 'pages_messaging',
          'status': 'granted'
        },
        {
          'permission': 'public_profile',
          'status': 'granted'
        }
      ]
    }.with_indifferent_access
  end

  let(:business_response) do
    {
      'data': [
        {
          'id': '369967346743673',
          'name': 'Passoz'
        },
        {
          'id': '223320012172799',
          'name': 'Development Test'
        }
      ],
      'paging': {
        'cursors': {
          'before': 'QVFIUnpEYXl1b3QyR1JRN3B5XzBfRnFCU1ozYV9Cem9EYVdFVFBwNmcyQVpEcVQ3ZAzFVUGtTVTVtWmFPbWxTZAzhmNU1oSDY1cVhJMVBWRHR6N1dOSnRiY1ZAR',
          'after': 'QVFIUktINVJIZA1VoYlJDeDJWUW9Qekl0UWN6MzU2UjRKb1FIZAGVLRGRjMzNQQmpja2xYbW16QTJQRkVic0RVQVpkLUtyZAGFvNl9xemJPZAWtFcU1nS0p0M1RR'
        }
      }
    }
  end

  let(:business_catalog_response) do
    {
      'data': [
        {
          'id': '221151689276865',
          'name': 'Productos Development'
        },
        {
          'id': '650552995708276',
          'name': 'Productos 2 Dev'
        }
      ],
      'paging': {
        'cursors': {
          'before': 'QVFIUlJEU3JXcFhxNDRROEp2N2JtZAFprX0JKSkRzTjdUQUlqUHY5aHYwNUVGR0lxYmU0Tkdia3J1a3lTdXN5SjhCY1NJQ0U4QnlLc3ZAqMnNRX0lHVFY4bGNR',
          'after': 'QVFIUm82Rkp3SXhNTGphSjZAYTW9mOUlrMF8zTGppR1RBMTZAwNzZAidmdsR19kUHU5TkhlcmhqbVZAuUVRxTWhZAMzRIcVRCV2NTWWZAXM2V4WXNfLXNwWXNQMFhR'
        }
      }
    }
  end

  describe '.validate_granted_permissions' do
    let(:oauth) do
      OmniAuth::AuthHash.new({
        credentials: OmniAuth::AuthHash.new({
          token: '1234567890'
        })
      })
    end

    context 'when the connection is made to messenger' do
      context 'when all the permissions to manage messenger are granted' do
        it 'returns true' do
          allow(Connection).to receive(:get_request).with(anything).and_return(permissions_granted)
          expect(described_class.validate_granted_permissions(oauth.credentials.token, 'messenger')[:granted_permissions]).to be true
        end
      end

      context 'when not all the permissions to manage messenger are granted' do
        it 'returns false' do
          allow(Connection).to receive(:get_request).with(anything).and_return(permissions_msn_declined)
          expect(described_class.validate_granted_permissions(oauth.credentials.token, 'messenger')[:granted_permissions]).to be false
        end
      end
    end

    context 'when the connection is made to facebook catalog' do
      context 'when all the permissions to manage facebook catalog are granted' do
        it 'returns true' do
          allow(Connection).to receive(:get_request).with(anything).and_return(permissions_granted)
          expect(described_class.validate_granted_permissions(oauth.credentials.token, 'catalog')[:granted_permissions]).to be true
        end
      end

      context 'when not all the permissions to manage facebook catalog are granted' do
        it 'returns false' do
          allow(Connection).to receive(:get_request).with(anything).and_return(permissions_catalog_declined)
          expect(described_class.validate_granted_permissions(oauth.credentials.token, 'catalog')[:granted_permissions]).to be false
        end
      end
    end
  end

  describe '#businesses' do
    it 'returns a list of businesses selected on integration process' do
      allow(Connection).to receive(:get_request).with(anything).and_return(business_response)
      expect(service_api.businesses).to eq(business_response)
    end
  end

  describe '#business_product_catalogs' do
    it 'returns a list of businesses selected on integration process' do
      allow(Connection).to receive(:get_request).with(anything).and_return(business_catalog_response)
      expect(service_api.business_product_catalogs('12345')).to eq(business_catalog_response)
    end
  end
end
