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

ActiveRecord::Schema.define(version: 2019_08_07_230431) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["filename", "checksum"], name: "index_active_storage_blobs_on_filename_and_checksum", unique: true
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
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

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "meli_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.jsonb "template", default: []
    t.index ["ancestry"], name: "index_categories_on_ancestry"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "retailer_id"
    t.string "phone"
    t.string "meli_nickname"
    t.integer "meli_customer_id"
    t.integer "id_type"
    t.string "id_number"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country_id"
    t.index ["retailer_id"], name: "index_customers_on_retailer_id"
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
    t.index ["customer_id"], name: "index_meli_retailers_on_customer_id"
    t.index ["retailer_id"], name: "index_meli_retailers_on_retailer_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.integer "quantity"
    t.decimal "unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_variation_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variation_id"], name: "index_order_items_on_product_variation_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id"
    t.integer "status"
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
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "product_variations", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "variation_meli_id"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variations_on_product_id"
    t.index ["variation_meli_id"], name: "index_product_variations_on_variation_meli_id", unique: true
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
    t.integer "sold_quantity"
    t.datetime "meli_start_time"
    t.string "meli_listing_type_id"
    t.datetime "meli_stop_time"
    t.datetime "meli_end_time"
    t.datetime "meli_expiration_time"
    t.string "meli_permalink"
    t.integer "category_id"
    t.integer "buying_mode"
    t.integer "condition", default: 0
    t.jsonb "ml_attributes", default: []
    t.bigint "main_picture_id"
    t.integer "status", default: 0
    t.integer "meli_status", default: 0
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["meli_product_id"], name: "index_products_on_meli_product_id", unique: true
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
    t.index ["customer_id"], name: "index_questions_on_customer_id"
    t.index ["order_id"], name: "index_questions_on_order_id"
    t.index ["product_id"], name: "index_questions_on_product_id"
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
    t.index ["email"], name: "index_retailer_users_on_email", unique: true
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
    t.index ["slug"], name: "index_retailers_on_slug", unique: true
  end

  create_table "templates", force: :cascade do |t|
    t.string "title"
    t.text "answer"
    t.bigint "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_for_questions", default: false
    t.boolean "enable_for_chats", default: false
    t.index ["retailer_id"], name: "index_templates_on_retailer_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "meli_retailers", "retailers"
  add_foreign_key "questions", "products"
end
