FactoryBot.define do
  factory :campaign do
    association :retailer, factory: [:retailer, :gupshup_integrated, :with_admin]
    association :whatsapp_template, factory: [:whatsapp_template, :with_text]
    contact_group { FactoryBot.build(:contact_group, :with_customers, retailer: retailer) }

    sequence :name do |n|
      "Campaña #{n}"
    end
    send_at { 2.minutes.from_now }
    content_params { ['{{first_name}}', '{{custom_field}}'] }

    trait :with_sent_messages do
      after(:build) do |campaign|
        customer = create(:customer, retailer: campaign.retailer, contact_groups: [campaign.contact_group])
        campaign.gupshup_whatsapp_messages = [
          create(
            :gupshup_whatsapp_message,
            :outbound,
            :notification,
            retailer: campaign.retailer,
            customer: customer,
            cost: customer.ws_bic_cost
          )
        ]
        campaign.save
      end
    end

    trait :with_karix_sent_messages do
      after(:build) do |campaign|
        customer = create(:customer, retailer: campaign.retailer, contact_groups: [campaign.contact_group])
        campaign.karix_whatsapp_messages = [
          create(
            :karix_whatsapp_message,
            :outbound,
            :notification,
            retailer: campaign.retailer,
            customer: customer,
            cost: campaign.retailer.ws_notification_cost
          )
        ]
        campaign.save
      end
    end
  end
end
