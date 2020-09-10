FactoryBot.define do
  factory :payment_method do
    stripe_pm_id { 'MyStripeIDHashString' }
    retailer
    payment_type { 'card' }
    payment_payload {
      {
        'id': 'pm_1GzoNgHiB9RqDUjMVVaNtHnE',
        'object': 'payment_method',
        'billing_details': {
          'address': {
            'city': nil,
            'country': nil,
            'line1': nil,
            'line2': nil,
            'postal_code': '24242',
            'state': nil
          },
          'email': nil,
          'name': nil,
          'phone': nil
        },
        'card': {
          'brand': 'visa',
          'checks': {
            'address_line1_check': nil,
            'address_postal_code_check': 'pass',
            'cvc_check': 'pass'
          },
          'country': 'US',
          'exp_month': 4,
          'exp_year': 2042,
          'fingerprint': 'WC1OHKUFBVIKfSp6',
          'funding': 'credit',
          'generated_from': nil,
          'last4': '4242',
          'networks': {
            'available': ['visa'],
            'preferred': nil
          },
          'three_d_secure_usage': {
            'supported': true
          },
          'wallet': nil
        },
        'created': 1593542433,
        'customer': 'cus_00000000000000',
        'livemode': false,
        'metadata': {},
        'type': 'card'
      }.to_json
    }
  end
end
