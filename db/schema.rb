# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_21_202809) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "adminpack"
  enable_extension "plpgsql"

  create_table "action_tags", force: :cascade do |t|
    t.bigint "chat_bot_action_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_bot_action_id"], name: "index_action_tags_on_chat_bot_action_id"
    t.index ["tag_id"], name: "index_action_tags_on_tag_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "additional_bot_answers", force: :cascade do |t|
    t.bigint "chat_bot_option_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_bot_option_id"], name: "index_additional_bot_answers_on_chat_bot_option_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "agent_customers", force: :cascade do |t|
    t.bigint "retailer_user_id", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_assignment_id"
    t.index ["customer_id"], name: "index_agent_customers_on_customer_id"
    t.index ["retailer_user_id"], name: "index_agent_customers_on_retailer_user_id"
    t.index ["team_assignment_id"], name: "index_agent_customers_on_team_assignment_id"
  end

  create_table "agent_notifications", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "retailer_user_id", null: false
    t.string "notification_type"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_agent_notifications_on_customer_id"
    t.index ["retailer_user_id"], name: "index_agent_notifications_on_retailer_user_id"
  end

  create_table "agent_teams", force: :cascade do |t|
    t.bigint "team_assignment_id"
    t.bigint "retailer_user_id"
    t.integer "max_assignments", default: 0
    t.integer "assigned_amount", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_user_id"], name: "index_agent_teams_on_retailer_user_id"
    t.index ["team_assignment_id"], name: "index_agent_teams_on_team_assignment_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "automatic_answers", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "message"
    t.integer "message_type"
    t.integer "interval"
    t.integer "status", default: 1
    t.integer "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_automatic_answers_on_retailer_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "title"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "remember_at"
    t.bigint "retailer_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "web_id"
    t.integer "remember"
    t.string "timezone"
    t.index ["retailer_id"], name: "index_calendar_events_on_retailer_id"
    t.index ["retailer_user_id"], name: "index_calendar_events_on_retailer_user_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.text "template_text"
    t.integer "status", default: 0
    t.datetime "send_at"
    t.jsonb "content_params"
    t.bigint "whatsapp_template_id"
    t.bigint "contact_group_id"
    t.bigint "retailer_id"
    t.string "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "cost", default: 0.0
    t.string "reason"
    t.index ["contact_group_id"], name: "index_campaigns_on_contact_group_id"
    t.index ["retailer_id"], name: "index_campaigns_on_retailer_id"
    t.index ["web_id"], name: "index_campaigns_on_web_id"
    t.index ["whatsapp_template_id"], name: "index_campaigns_on_whatsapp_template_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "meli_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.jsonb "template", default: []
    t.integer "status", default: 0
    t.index ["ancestry"], name: "index_categories_on_ancestry"
    t.index ["meli_id"], name: "index_categories_on_meli_id", unique: true, where: "(meli_id IS NOT NULL)"
  end

  create_table "chat_bot_actions", force: :cascade do |t|
    t.bigint "chat_bot_option_id"
    t.bigint "retailer_user_id"
    t.integer "action_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_field"
    t.string "webhook"
    t.integer "action_event", default: 0
    t.string "username"
    t.string "password"
    t.integer "payload_type", default: 0
    t.jsonb "data", default: []
    t.jsonb "headers", default: []
    t.integer "classification", default: 0
    t.string "exit_message"
    t.bigint "customer_related_field_id"
    t.bigint "jump_option_id"
    t.index ["chat_bot_option_id"], name: "index_chat_bot_actions_on_chat_bot_option_id"
    t.index ["customer_related_field_id"], name: "index_chat_bot_actions_on_customer_related_field_id"
    t.index ["jump_option_id"], name: "index_chat_bot_actions_on_jump_option_id"
    t.index ["retailer_user_id"], name: "index_chat_bot_actions_on_retailer_user_id"
  end

  create_table "chat_bot_customers", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "chat_bot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_bot_id"], name: "index_chat_bot_customers_on_chat_bot_id"
    t.index ["customer_id"], name: "index_chat_bot_customers_on_customer_id"
  end

  create_table "chat_bot_options", force: :cascade do |t|
    t.bigint "chat_bot_id"
    t.string "text"
    t.string "ancestry"
    t.integer "position"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "option_deleted", default: false
    t.integer "option_type", default: 0
    t.boolean "skip_option", default: false
    t.index ["ancestry"], name: "index_chat_bot_options_on_ancestry"
    t.index ["chat_bot_id"], name: "index_chat_bot_options_on_chat_bot_id"
  end

  create_table "chat_bots", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "name"
    t.string "trigger"
    t.integer "failed_attempts"
    t.string "goodbye_message"
    t.boolean "any_interaction", default: false
    t.string "web_id"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_message"
    t.boolean "repeat_menu_on_failure", default: false
    t.float "reactivate_after"
    t.integer "on_failed_attempt"
    t.string "on_failed_attempt_message"
    t.integer "platform"
    t.index ["retailer_id"], name: "index_chat_bots_on_retailer_id"
  end

  create_table "contact_group_customers", force: :cascade do |t|
    t.bigint "contact_group_id"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_group_id"], name: "index_contact_group_customers_on_contact_group_id"
    t.index ["customer_id"], name: "index_contact_group_customers_on_customer_id"
  end

  create_table "contact_groups", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "name"
    t.string "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "imported", default: false
    t.boolean "archived", default: false
    t.index ["retailer_id"], name: "index_contact_groups_on_retailer_id"
    t.index ["web_id"], name: "index_contact_groups_on_web_id"
  end

  create_table "customer_bot_options", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "chat_bot_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_bot_option_id"], name: "index_customer_bot_options_on_chat_bot_option_id"
    t.index ["customer_id"], name: "index_customer_bot_options_on_customer_id"
  end

  create_table "customer_hubspot_fields", force: :cascade do |t|
    t.string "customer_field"
    t.bigint "hubspot_field_id"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hs_tag", default: false
    t.index ["customer_field", "hubspot_field_id", "retailer_id"], name: "chf_customer_field_husbpot_field_retailer", unique: true
    t.index ["hubspot_field_id"], name: "index_customer_hubspot_fields_on_hubspot_field_id"
    t.index ["retailer_id"], name: "index_customer_hubspot_fields_on_retailer_id"
  end

  create_table "customer_related_data", force: :cascade do |t|
    t.bigint "customer_related_field_id"
    t.bigint "customer_id"
    t.string "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_related_data_on_customer_id"
    t.index ["customer_related_field_id"], name: "index_customer_related_data_on_customer_related_field_id"
  end

  create_table "customer_related_fields", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "name"
    t.string "identifier"
    t.integer "field_type", default: 0
    t.string "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "list_options", default: []
    t.index ["retailer_id"], name: "index_customer_related_fields_on_retailer_id"
  end

  create_table "customer_tags", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_tags_on_customer_id"
    t.index ["tag_id"], name: "index_customer_tags_on_tag_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "retailer_id"
    t.string "phone"
    t.integer "meli_customer_id"
    t.string "meli_nickname"
    t.integer "id_type"
    t.string "id_number"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country_id"
    t.boolean "valid_customer", default: false
    t.string "psid"
    t.string "web_id"
    t.string "karix_whatsapp_phone"
    t.text "notes"
    t.boolean "whatsapp_opt_in", default: false
    t.string "whatsapp_name"
    t.boolean "unread_whatsapp_chat", default: false
    t.boolean "unread_messenger_chat", default: false
    t.boolean "active_bot", default: false
    t.bigint "chat_bot_option_id"
    t.integer "failed_bot_attempts", default: 0
    t.boolean "allow_start_bots", default: false
    t.jsonb "endpoint_response", default: {}
    t.jsonb "endpoint_failed_response", default: {}
    t.float "ws_notification_cost", default: 0.0672
    t.boolean "hs_active"
    t.string "hs_id"
    t.string "number_to_use"
    t.boolean "api_created", default: false
    t.boolean "ws_active", default: false
    t.datetime "last_chat_interaction"
    t.index ["chat_bot_option_id"], name: "index_customers_on_chat_bot_option_id"
    t.index ["last_chat_interaction"], name: "index_customers_on_last_chat_interaction"
    t.index ["psid"], name: "index_customers_on_psid"
    t.index ["retailer_id"], name: "index_customers_on_retailer_id"
    t.index ["ws_active"], name: "index_customers_on_ws_active"
  end

  create_table "demo_request_leads", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "company"
    t.integer "employee_quantity"
    t.string "country"
    t.string "phone"
    t.string "message"
    t.string "problem_to_resolve"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facebook_catalogs", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "uid"
    t.string "name"
    t.string "business_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_facebook_catalogs_on_retailer_id"
  end

  create_table "facebook_messages", force: :cascade do |t|
    t.string "sender_uid"
    t.string "id_client"
    t.bigint "facebook_retailer_id"
    t.text "text"
    t.string "mid"
    t.string "reply_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.date "date_read"
    t.boolean "sent_from_mercately", default: false
    t.boolean "sent_by_retailer", default: false
    t.string "file_type"
    t.string "url"
    t.string "file_data"
    t.string "filename"
    t.bigint "retailer_user_id"
    t.index ["customer_id"], name: "index_facebook_messages_on_customer_id"
    t.index ["facebook_retailer_id"], name: "index_facebook_messages_on_facebook_retailer_id"
    t.index ["retailer_user_id"], name: "index_facebook_messages_on_retailer_user_id"
  end

  create_table "facebook_retailers", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "uid"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_facebook_retailers_on_retailer_id"
  end

  create_table "gs_templates", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "label"
    t.integer "key", default: 0, null: false
    t.string "category"
    t.text "text"
    t.text "example"
    t.string "language", default: "spanish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retailer_id"
    t.text "reason"
    t.boolean "submitted", default: false
    t.index ["retailer_id"], name: "index_gs_templates_on_retailer_id"
  end

  create_table "gupshup_whatsapp_messages", force: :cascade do |t|
    t.bigint "retailer_id"
    t.bigint "customer_id"
    t.string "whatsapp_message_id"
    t.string "gupshup_message_id"
    t.integer "status", null: false
    t.string "direction", null: false
    t.json "message_payload"
    t.string "source", null: false
    t.string "destination", null: false
    t.string "channel", null: false
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "read_at"
    t.boolean "error"
    t.json "error_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_type"
    t.bigint "retailer_user_id"
    t.float "cost"
    t.string "message_identifier"
    t.bigint "campaign_id"
    t.index ["campaign_id"], name: "index_gupshup_whatsapp_messages_on_campaign_id"
    t.index ["customer_id"], name: "index_gupshup_whatsapp_messages_on_customer_id"
    t.index ["gupshup_message_id"], name: "index_gupshup_whatsapp_messages_on_gupshup_message_id"
    t.index ["retailer_id"], name: "index_gupshup_whatsapp_messages_on_retailer_id"
    t.index ["retailer_user_id"], name: "index_gupshup_whatsapp_messages_on_retailer_user_id"
    t.index ["whatsapp_message_id"], name: "index_gupshup_whatsapp_messages_on_whatsapp_message_id"
  end

  create_table "hubspot_fields", force: :cascade do |t|
    t.string "hubspot_field"
    t.string "hubspot_label"
    t.string "hubspot_type"
    t.boolean "taken", default: false
    t.boolean "deleted", default: false
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id", "hubspot_field"], name: "index_hubspot_fields_on_retailer_id_and_hubspot_field", unique: true
    t.index ["retailer_id"], name: "index_hubspot_fields_on_retailer_id"
  end

  create_table "karix_whatsapp_messages", force: :cascade do |t|
    t.string "uid"
    t.string "account_uid"
    t.string "source"
    t.string "destination"
    t.string "country"
    t.string "content_type"
    t.string "content_text"
    t.string "content_media_url"
    t.string "content_media_caption"
    t.string "content_media_type"
    t.string "content_location_longitude"
    t.string "content_location_latitude"
    t.string "content_location_label"
    t.string "content_location_address"
    t.datetime "created_time"
    t.datetime "sent_time"
    t.datetime "delivered_time"
    t.datetime "updated_time"
    t.string "status"
    t.string "channel"
    t.string "direction"
    t.string "error_code"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retailer_id"
    t.bigint "customer_id"
    t.string "message_type"
    t.bigint "retailer_user_id"
    t.float "cost"
    t.string "message_identifier"
    t.bigint "campaign_id"
    t.index ["campaign_id"], name: "index_karix_whatsapp_messages_on_campaign_id"
    t.index ["customer_id"], name: "index_karix_whatsapp_messages_on_customer_id"
    t.index ["retailer_id"], name: "index_karix_whatsapp_messages_on_retailer_id"
    t.index ["retailer_user_id"], name: "index_karix_whatsapp_messages_on_retailer_user_id"
    t.index ["uid"], name: "index_karix_whatsapp_messages_on_uid", unique: true
  end

  create_table "meli_customers", force: :cascade do |t|
    t.string "access_token"
    t.string "meli_user_id"
    t.string "refresh_token"
    t.string "nickname"
    t.string "email"
    t.integer "points"
    t.string "link"
    t.string "seller_experience"
    t.string "seller_reputation_level_id"
    t.integer "transactions_canceled"
    t.integer "transactions_completed"
    t.integer "ratings_negative"
    t.integer "ratings_neutral"
    t.integer "ratings_positive"
    t.integer "ratings_total"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "buyer_canceled_transactions"
    t.integer "buyer_completed_transactions"
    t.integer "buyer_canceled_paid_transactions"
    t.integer "buyer_unrated_paid_transactions"
    t.integer "buyer_unrated_total_transactions"
    t.integer "buyer_not_yet_rated_paid_transactions"
    t.integer "buyer_not_yet_rated_total_transactions"
    t.datetime "meli_registration_date"
    t.string "phone_area"
    t.boolean "phone_verified"
  end

  create_table "meli_retailers", force: :cascade do |t|
    t.string "access_token"
    t.string "meli_user_id"
    t.string "refresh_token"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname"
    t.string "email"
    t.integer "points"
    t.string "link"
    t.string "seller_experience"
    t.string "seller_reputation_level_id"
    t.integer "transactions_canceled"
    t.integer "transactions_completed"
    t.integer "ratings_negative"
    t.integer "ratings_neutral"
    t.integer "ratings_positive"
    t.integer "ratings_total"
    t.bigint "customer_id"
    t.string "phone"
    t.boolean "has_meli_info", default: false
    t.datetime "meli_token_updated_at"
    t.datetime "meli_info_updated_at"
    t.boolean "meli_user_active", default: true
    t.index ["customer_id"], name: "index_meli_retailers_on_customer_id"
    t.index ["retailer_id"], name: "index_meli_retailers_on_retailer_id"
  end

  create_table "mobile_tokens", force: :cascade do |t|
    t.bigint "retailer_user_id"
    t.string "device"
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "encrypted_token_salt"
    t.datetime "expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_push_token"
    t.index ["device", "retailer_user_id"], name: "index_mobile_tokens_on_device_and_retailer_user_id", unique: true
    t.index ["retailer_user_id"], name: "index_mobile_tokens_on_retailer_user_id"
  end

  create_table "option_sub_lists", force: :cascade do |t|
    t.bigint "chat_bot_option_id"
    t.string "value_to_save"
    t.string "value_to_show"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_bot_option_id"], name: "index_option_sub_lists_on_chat_bot_option_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.integer "quantity"
    t.decimal "unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_variation_id"
    t.boolean "from_ml", default: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variation_id"], name: "index_order_items_on_product_variation_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meli_order_id"
    t.string "currency_id"
    t.float "total_amount"
    t.datetime "date_closed"
    t.integer "merc_status", default: 0
    t.integer "feedback_reason"
    t.string "feedback_message"
    t.integer "feedback_rating"
    t.string "web_id"
    t.string "pack_id"
    t.text "notes"
    t.bigint "retailer_user_id"
    t.bigint "sales_channel_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["meli_order_id"], name: "index_orders_on_meli_order_id", unique: true
    t.index ["retailer_user_id"], name: "index_orders_on_retailer_user_id"
    t.index ["sales_channel_id"], name: "index_orders_on_sales_channel_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "stripe_pm_id", null: false
    t.bigint "retailer_id"
    t.string "payment_type", null: false
    t.json "payment_payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_payment_methods_on_retailer_id"
  end

  create_table "payment_plans", force: :cascade do |t|
    t.bigint "retailer_id"
    t.decimal "price", default: "0.0"
    t.date "start_date", default: -> { "CURRENT_TIMESTAMP" }
    t.date "next_pay_date"
    t.integer "status", default: 0
    t.integer "plan", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "karix_available_messages", default: 0
    t.integer "karix_available_notifications", default: 0
    t.index ["retailer_id"], name: "index_payment_plans_on_retailer_id"
  end

  create_table "paymentez_credit_cards", force: :cascade do |t|
    t.string "card_type"
    t.string "number"
    t.string "name"
    t.bigint "retailer_id"
    t.string "token"
    t.string "status"
    t.string "expiry_month"
    t.string "expiry_year"
    t.boolean "deleted", default: false
    t.boolean "main", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_paymentez_credit_cards_on_retailer_id"
  end

  create_table "paymentez_transactions", force: :cascade do |t|
    t.string "status"
    t.string "payment_date"
    t.decimal "amount"
    t.string "authorization_code"
    t.integer "installments"
    t.string "dev_reference"
    t.string "message"
    t.string "carrier_code"
    t.string "pt_id"
    t.integer "status_detail"
    t.string "transaction_reference"
    t.bigint "retailer_id"
    t.bigint "payment_plan_id"
    t.bigint "paymentez_credit_card_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_plan_id"], name: "index_paymentez_transactions_on_payment_plan_id"
    t.index ["paymentez_credit_card_id"], name: "index_paymentez_transactions_on_paymentez_credit_card_id"
    t.index ["retailer_id"], name: "index_paymentez_transactions_on_retailer_id"
  end

  create_table "product_variations", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "variation_meli_id"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["product_id"], name: "index_product_variations_on_product_id"
    t.index ["variation_meli_id"], name: "index_product_variations_on_variation_meli_id", unique: true, where: "(variation_meli_id IS NOT NULL)"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.decimal "price"
    t.integer "available_quantity"
    t.text "description"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meli_product_id"
    t.string "meli_site_id"
    t.string "subtitle"
    t.decimal "base_price"
    t.decimal "original_price"
    t.integer "initial_quantity"
    t.integer "sold_quantity", default: 0
    t.datetime "meli_start_time"
    t.string "meli_listing_type_id"
    t.datetime "meli_stop_time"
    t.datetime "meli_end_time"
    t.string "meli_permalink"
    t.integer "category_id"
    t.integer "buying_mode"
    t.integer "condition", default: 0
    t.jsonb "ml_attributes", default: []
    t.bigint "main_picture_id"
    t.integer "status", default: 0
    t.integer "meli_status"
    t.integer "from", default: 0
    t.string "code"
    t.string "web_id"
    t.jsonb "meli_parent", default: []
    t.string "facebook_product_id"
    t.string "manufacturer_part_number"
    t.string "gtin"
    t.string "brand"
    t.string "url"
    t.boolean "connected_to_facebook", default: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["facebook_product_id"], name: "index_products_on_facebook_product_id", unique: true, where: "(facebook_product_id IS NOT NULL)"
    t.index ["meli_product_id"], name: "index_products_on_meli_product_id", unique: true, where: "(meli_product_id IS NOT NULL)"
    t.index ["retailer_id", "code"], name: "index_products_on_retailer_id_and_code", unique: true
    t.index ["retailer_id"], name: "index_products_on_retailer_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "product_id"
    t.string "answer"
    t.string "question"
    t.string "meli_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.boolean "deleted_from_listing", default: false
    t.boolean "hold", default: false
    t.integer "status"
    t.datetime "date_read"
    t.string "site_id"
    t.integer "sender_id"
    t.bigint "order_id"
    t.integer "answer_status"
    t.datetime "date_created_question"
    t.datetime "date_created_answer"
    t.integer "meli_question_type"
    t.boolean "answered", default: false
    t.string "web_id"
    t.index ["customer_id"], name: "index_questions_on_customer_id"
    t.index ["meli_id"], name: "index_questions_on_meli_id", unique: true
    t.index ["order_id"], name: "index_questions_on_order_id"
    t.index ["product_id"], name: "index_questions_on_product_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.bigint "retailer_id"
    t.bigint "customer_id"
    t.bigint "retailer_user_id"
    t.bigint "whatsapp_template_id"
    t.bigint "gupshup_whatsapp_message_id"
    t.bigint "karix_whatsapp_message_id"
    t.jsonb "content_params"
    t.datetime "send_at"
    t.datetime "send_at_timezone"
    t.string "timezone"
    t.string "web_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "template_text"
    t.index ["customer_id"], name: "index_reminders_on_customer_id"
    t.index ["gupshup_whatsapp_message_id"], name: "index_reminders_on_gupshup_whatsapp_message_id"
    t.index ["karix_whatsapp_message_id"], name: "index_reminders_on_karix_whatsapp_message_id"
    t.index ["retailer_id"], name: "index_reminders_on_retailer_id"
    t.index ["retailer_user_id"], name: "index_reminders_on_retailer_user_id"
    t.index ["whatsapp_template_id"], name: "index_reminders_on_whatsapp_template_id"
  end

  create_table "retailer_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "agree_terms"
    t.jsonb "onboarding_status", default: {"step"=>0, "skipped"=>false, "completed"=>false}
    t.string "provider"
    t.string "uid"
    t.string "facebook_access_token"
    t.date "facebook_access_token_expiration"
    t.boolean "retailer_admin", default: true
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "removed_from_team", default: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "retailer_supervisor", default: false
    t.boolean "only_assigned", default: false
    t.index ["email"], name: "index_retailer_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_retailer_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_retailer_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_retailer_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_retailer_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_retailer_users_on_reset_password_token", unique: true
    t.index ["retailer_id"], name: "index_retailer_users_on_retailer_id"
  end

  create_table "retailers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "id_number"
    t.integer "id_type"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "phone_number"
    t.boolean "phone_verified"
    t.string "retailer_number"
    t.boolean "whats_app_enabled", default: false
    t.string "karix_whatsapp_phone"
    t.string "encrypted_api_key"
    t.datetime "last_api_key_modified_date"
    t.string "encrypted_api_key_iv"
    t.string "encrypted_api_key_salt"
    t.float "ws_balance", default: 0.0
    t.float "ws_next_notification_balance", default: 1.5
    t.float "ws_notification_cost", default: 0.0672
    t.float "ws_conversation_cost", default: 0.0
    t.string "gupshup_phone_number"
    t.string "gupshup_src_name"
    t.string "karix_account_uid"
    t.string "karix_account_token"
    t.boolean "unlimited_account", default: false
    t.boolean "ecu_charges", default: false
    t.boolean "allow_bots", default: false
    t.boolean "int_charges", default: true
    t.string "gupshup_api_key"
    t.boolean "manage_team_assignment", default: false
    t.boolean "show_stats", default: false
    t.boolean "allow_voice_notes", default: true
    t.integer "hubspot_match", default: 0
    t.datetime "hs_expires_in"
    t.string "hs_access_token"
    t.string "hs_refresh_token"
    t.boolean "all_customers_hs_integrated", default: true
    t.boolean "allow_send_videos", default: false
    t.boolean "hs_tags", default: false
    t.boolean "allow_multiple_answers", default: false
    t.string "hs_id"
    t.integer "max_agents", default: 2
    t.boolean "campaings_access", default: false
    t.index ["encrypted_api_key"], name: "index_retailers_on_encrypted_api_key"
    t.index ["gupshup_src_name"], name: "index_retailers_on_gupshup_src_name", unique: true
    t.index ["slug"], name: "index_retailers_on_slug", unique: true
  end

  create_table "sales_channels", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "title"
    t.string "web_id"
    t.integer "channel_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_sales_channels_on_retailer_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "stripe_transactions", force: :cascade do |t|
    t.integer "retailer_id"
    t.string "stripe_id"
    t.integer "amount"
    t.bigint "payment_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id"], name: "index_stripe_transactions_on_payment_method_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "web_id"
    t.index ["retailer_id"], name: "index_tags_on_retailer_id"
  end

  create_table "team_assignments", force: :cascade do |t|
    t.bigint "retailer_id"
    t.string "name"
    t.boolean "active_assignment", default: false
    t.boolean "default_assignment", default: false
    t.string "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_team_assignments_on_retailer_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title"
    t.text "answer"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_for_questions", default: false
    t.boolean "enable_for_chats", default: false
    t.string "web_id"
    t.boolean "enable_for_messenger", default: false
    t.boolean "enable_for_whatsapp", default: false
    t.bigint "retailer_user_id"
    t.boolean "global", default: false
    t.index ["retailer_id"], name: "index_templates_on_retailer_id"
    t.index ["retailer_user_id"], name: "index_templates_on_retailer_user_id"
  end

  create_table "top_ups", force: :cascade do |t|
    t.bigint "retailer_id"
    t.float "amount", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_top_ups_on_retailer_id"
  end

  create_table "whatsapp_templates", force: :cascade do |t|
    t.bigint "retailer_id"
    t.text "text", default: ""
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "template_type", default: 0, null: false
    t.string "gupshup_template_id"
    t.index ["retailer_id"], name: "index_whatsapp_templates_on_retailer_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_customers", "customers"
  add_foreign_key "agent_customers", "retailer_users"
  add_foreign_key "agent_notifications", "customers"
  add_foreign_key "agent_notifications", "retailer_users"
  add_foreign_key "calendar_events", "retailer_users"
  add_foreign_key "calendar_events", "retailers"
  add_foreign_key "campaigns", "contact_groups"
  add_foreign_key "campaigns", "retailers"
  add_foreign_key "campaigns", "whatsapp_templates"
  add_foreign_key "chat_bot_actions", "chat_bot_options", column: "jump_option_id"
  add_foreign_key "contact_group_customers", "contact_groups"
  add_foreign_key "contact_group_customers", "customers"
  add_foreign_key "contact_groups", "retailers"
  add_foreign_key "customer_hubspot_fields", "hubspot_fields"
  add_foreign_key "customer_hubspot_fields", "retailers"
  add_foreign_key "facebook_catalogs", "retailers"
  add_foreign_key "facebook_messages", "customers"
  add_foreign_key "facebook_messages", "facebook_retailers"
  add_foreign_key "facebook_retailers", "retailers"
  add_foreign_key "gs_templates", "retailers"
  add_foreign_key "gupshup_whatsapp_messages", "customers"
  add_foreign_key "gupshup_whatsapp_messages", "retailers"
  add_foreign_key "hubspot_fields", "retailers"
  add_foreign_key "karix_whatsapp_messages", "customers"
  add_foreign_key "karix_whatsapp_messages", "retailers"
  add_foreign_key "meli_retailers", "retailers"
  add_foreign_key "mobile_tokens", "retailer_users"
  add_foreign_key "payment_methods", "retailers"
  add_foreign_key "payment_plans", "retailers"
  add_foreign_key "paymentez_transactions", "payment_plans"
  add_foreign_key "paymentez_transactions", "paymentez_credit_cards"
  add_foreign_key "paymentez_transactions", "retailers"
  add_foreign_key "questions", "products"
end
