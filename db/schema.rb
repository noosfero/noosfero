# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160408011720) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuse_reports", force: :cascade do |t|
    t.integer  "reporter_id"
    t.integer  "abuse_complaint_id"
    t.text     "content"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "action_tracker", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.text     "params"
    t.string   "verb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count", default: 0
    t.boolean  "visible",        default: true
  end

  add_index "action_tracker", ["target_id", "target_type"], name: "index_action_tracker_on_dispatcher_id_and_dispatcher_type", using: :btree
  add_index "action_tracker", ["user_id", "user_type"], name: "index_action_tracker_on_user_id_and_user_type", using: :btree
  add_index "action_tracker", ["verb"], name: "index_action_tracker_on_verb", using: :btree

  create_table "action_tracker_notifications", force: :cascade do |t|
    t.integer "action_tracker_id"
    t.integer "profile_id"
  end

  add_index "action_tracker_notifications", ["action_tracker_id"], name: "index_action_tracker_notifications_on_action_tracker_id", using: :btree
  add_index "action_tracker_notifications", ["profile_id", "action_tracker_id"], name: "index_action_tracker_notif_on_prof_id_act_tracker_id", unique: true, using: :btree
  add_index "action_tracker_notifications", ["profile_id"], name: "index_action_tracker_notifications_on_profile_id", using: :btree

  create_table "article_followers", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "article_id"
    t.datetime "since"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_followers", ["article_id"], name: "index_article_followers_on_article_id", using: :btree
  add_index "article_followers", ["person_id", "article_id"], name: "index_article_followers_on_person_id_and_article_id", unique: true, using: :btree
  add_index "article_followers", ["person_id"], name: "index_article_followers_on_person_id", using: :btree

  create_table "article_privacy_exceptions", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "person_id"
  end

  create_table "article_versions", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slug"
    t.text     "path",                 default: ""
    t.integer  "parent_id"
    t.text     "body"
    t.text     "abstract"
    t.integer  "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "last_changed_by_id"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.string   "versioned_type"
    t.integer  "comments_count"
    t.boolean  "advertise",            default: true
    t.boolean  "published",            default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "children_count",       default: 0
    t.boolean  "accept_comments",      default: true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",      default: false
    t.integer  "hits",                 default: 0
    t.datetime "published_at"
    t.string   "source"
    t.boolean  "highlighted",          default: false
    t.string   "external_link"
    t.boolean  "thumbnails_processed", default: false
    t.boolean  "is_image",             default: false
    t.integer  "translation_of_id"
    t.string   "language"
    t.string   "source_name"
    t.integer  "license_id"
    t.integer  "image_id"
    t.integer  "position"
    t.integer  "spam_comments_count",  default: 0
    t.integer  "author_id"
    t.integer  "created_by_id"
  end

  add_index "article_versions", ["article_id"], name: "index_article_versions_on_article_id", using: :btree
  add_index "article_versions", ["parent_id"], name: "index_article_versions_on_parent_id", using: :btree
  add_index "article_versions", ["path", "profile_id"], name: "index_article_versions_on_path_and_profile_id", using: :btree
  add_index "article_versions", ["path"], name: "index_article_versions_on_path", using: :btree
  add_index "article_versions", ["published_at", "id"], name: "index_article_versions_on_published_at_and_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "path",                 default: ""
    t.integer  "parent_id"
    t.text     "body"
    t.text     "abstract"
    t.integer  "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "last_changed_by_id"
    t.integer  "version"
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "comments_count",       default: 0
    t.boolean  "advertise",            default: true
    t.boolean  "published",            default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "children_count",       default: 0
    t.boolean  "accept_comments",      default: true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",      default: true
    t.integer  "hits",                 default: 0
    t.datetime "published_at"
    t.string   "source"
    t.boolean  "highlighted",          default: false
    t.string   "external_link"
    t.boolean  "thumbnails_processed", default: false
    t.boolean  "is_image",             default: false
    t.integer  "translation_of_id"
    t.string   "language"
    t.string   "source_name"
    t.integer  "license_id"
    t.integer  "image_id"
    t.integer  "position"
    t.integer  "spam_comments_count",  default: 0
    t.integer  "author_id"
    t.integer  "created_by_id"
    t.boolean  "show_to_followers",    default: true
    t.integer  "followers_count",      default: 0
    t.boolean  "archived",             default: false
  end

  add_index "articles", ["comments_count"], name: "index_articles_on_comments_count", using: :btree
  add_index "articles", ["created_at"], name: "index_articles_on_created_at", using: :btree
  add_index "articles", ["hits"], name: "index_articles_on_hits", using: :btree
  add_index "articles", ["name"], name: "index_articles_on_name", using: :btree
  add_index "articles", ["parent_id"], name: "index_articles_on_parent_id", using: :btree
  add_index "articles", ["path", "profile_id"], name: "index_articles_on_path_and_profile_id", using: :btree
  add_index "articles", ["path"], name: "index_articles_on_path", using: :btree
  add_index "articles", ["profile_id"], name: "index_articles_on_profile_id", using: :btree
  add_index "articles", ["published_at", "id"], name: "index_articles_on_published_at_and_id", using: :btree
  add_index "articles", ["slug"], name: "index_articles_on_slug", using: :btree
  add_index "articles", ["translation_of_id"], name: "index_articles_on_translation_of_id", using: :btree
  add_index "articles", ["type", "parent_id"], name: "index_articles_on_type_and_parent_id", using: :btree
  add_index "articles", ["type", "profile_id"], name: "index_articles_on_type_and_profile_id", using: :btree
  add_index "articles", ["type"], name: "index_articles_on_type", using: :btree

  create_table "articles_categories", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "category_id"
    t.boolean "virtual",     default: false
  end

  add_index "articles_categories", ["article_id"], name: "index_articles_categories_on_article_id", using: :btree
  add_index "articles_categories", ["category_id"], name: "index_articles_categories_on_category_id", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.string   "title"
    t.integer  "box_id"
    t.string   "type"
    t.text     "settings"
    t.integer  "position"
    t.boolean  "enabled",         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fetched_at"
    t.boolean  "mirror",          default: false
    t.integer  "mirror_block_id"
    t.integer  "observers_id"
    t.string   "subtitle",        default: ""
  end

  add_index "blocks", ["box_id"], name: "index_blocks_on_box_id", using: :btree
  add_index "blocks", ["enabled"], name: "index_blocks_on_enabled", using: :btree
  add_index "blocks", ["fetched_at"], name: "index_blocks_on_fetched_at", using: :btree
  add_index "blocks", ["type"], name: "index_blocks_on_type", using: :btree

  create_table "boxes", force: :cascade do |t|
    t.string  "owner_type"
    t.integer "owner_id"
    t.integer "position"
  end

  add_index "boxes", ["owner_id", "owner_type"], name: "index_boxes_on_owner_type_and_owner_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string  "name"
    t.string  "slug"
    t.text    "path",                      default: ""
    t.integer "environment_id"
    t.integer "parent_id"
    t.string  "type"
    t.float   "lat"
    t.float   "lng"
    t.boolean "display_in_menu",           default: false
    t.integer "children_count",            default: 0
    t.boolean "accept_products",           default: true
    t.integer "image_id"
    t.string  "acronym"
    t.string  "abbreviation"
    t.string  "display_color",   limit: 6
    t.text    "ancestry"
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "categories_profiles", id: false, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "category_id"
    t.boolean "virtual",     default: false
  end

  add_index "categories_profiles", ["category_id"], name: "index_categories_profiles_on_category_id", using: :btree
  add_index "categories_profiles", ["profile_id"], name: "index_categories_profiles_on_profile_id", using: :btree

  create_table "certifiers", force: :cascade do |t|
    t.string   "name",           null: false
    t.text     "description"
    t.string   "link"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer  "from_id",    null: false
    t.integer  "to_id",      null: false
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "chat_messages", ["created_at"], name: "index_chat_messages_on_created_at", using: :btree
  add_index "chat_messages", ["from_id"], name: "index_chat_messages_on_from_id", using: :btree
  add_index "chat_messages", ["to_id"], name: "index_chat_messages_on_to_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "source_id"
    t.integer  "author_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.integer  "reply_of_id"
    t.string   "ip_address"
    t.boolean  "spam"
    t.string   "source_type"
    t.string   "user_agent"
    t.string   "referrer"
    t.text     "settings"
  end

  add_index "comments", ["source_id", "spam"], name: "index_comments_on_source_id_and_spam", using: :btree

  create_table "contact_lists", force: :cascade do |t|
    t.text     "list"
    t.string   "error_fetching"
    t.boolean  "fetched",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.string   "customized_type", default: "",    null: false
    t.integer  "customized_id",   default: 0,     null: false
    t.boolean  "public",          default: false, null: false
    t.integer  "custom_field_id", default: 0,     null: false
    t.text     "value",           default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_field_values", ["customized_type", "customized_id", "custom_field_id"], name: "index_custom_field_values", unique: true, using: :btree

  create_table "custom_fields", force: :cascade do |t|
    t.string   "name"
    t.string   "format",          default: ""
    t.text     "default_value",   default: ""
    t.string   "customized_type"
    t.text     "extras",          default: ""
    t.boolean  "active",          default: false
    t.boolean  "required",        default: false
    t.boolean  "signup",          default: false
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "moderation_task", default: false
  end

  add_index "custom_fields", ["customized_type", "name", "environment_id"], name: "index_custom_field", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string  "name"
    t.string  "owner_type"
    t.integer "owner_id"
    t.boolean "is_default",      default: false
    t.string  "google_maps_key"
  end

  add_index "domains", ["is_default"], name: "index_domains_on_is_default", using: :btree
  add_index "domains", ["name"], name: "index_domains_on_name", using: :btree
  add_index "domains", ["owner_id", "owner_type", "is_default"], name: "index_domains_on_owner_id_and_owner_type_and_is_default", using: :btree
  add_index "domains", ["owner_id", "owner_type"], name: "index_domains_on_owner_id_and_owner_type", using: :btree

  create_table "email_templates", force: :cascade do |t|
    t.string   "name"
    t.string   "template_type"
    t.string   "subject"
    t.text     "body"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "environments", force: :cascade do |t|
    t.string   "name"
    t.string   "contact_email"
    t.boolean  "is_default"
    t.text     "settings"
    t.text     "design_data"
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme",                        default: "default",              null: false
    t.text     "terms_of_use_acceptance_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reports_lower_bound",          default: 0,                      null: false
    t.string   "redirection_after_login",      default: "keep_on_same_page"
    t.text     "signup_welcome_text"
    t.string   "languages"
    t.string   "default_language"
    t.string   "noreply_email"
    t.string   "redirection_after_signup",     default: "keep_on_same_page"
    t.string   "date_format",                  default: "month_name_with_year"
    t.boolean  "enable_feed_proxy",            default: false
    t.string   "http_feed_proxy"
    t.string   "https_feed_proxy"
    t.boolean  "disable_feed_ssl",             default: false
  end

  create_table "external_feeds", force: :cascade do |t|
    t.string   "feed_title"
    t.datetime "fetched_at"
    t.text     "address"
    t.integer  "blog_id",                      null: false
    t.boolean  "enabled",       default: true, null: false
    t.boolean  "only_once",     default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error_message"
    t.integer  "update_errors", default: 0
  end

  add_index "external_feeds", ["blog_id"], name: "index_external_feeds_on_blog_id", using: :btree
  add_index "external_feeds", ["enabled"], name: "index_external_feeds_on_enabled", using: :btree
  add_index "external_feeds", ["fetched_at"], name: "index_external_feeds_on_fetched_at", using: :btree

  create_table "favorite_enterprise_people", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "enterprise_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_enterprise_people", ["enterprise_id"], name: "index_favorite_enterprise_people_on_enterprise_id", using: :btree
  add_index "favorite_enterprise_people", ["person_id", "enterprise_id"], name: "index_favorite_enterprise_people_on_person_id_and_enterprise_id", using: :btree
  add_index "favorite_enterprise_people", ["person_id"], name: "index_favorite_enterprise_people_on_person_id", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.string   "group"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["person_id", "friend_id"], name: "index_friendships_on_person_id_and_friend_id", using: :btree
  add_index "friendships", ["person_id"], name: "index_friendships_on_person_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "thumbnails_processed", default: false
    t.string  "label",                default: ""
  end

  add_index "images", ["parent_id"], name: "index_images_on_parent_id", using: :btree

  create_table "inputs", force: :cascade do |t|
    t.integer  "product_id",                                 null: false
    t.integer  "product_category_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.decimal  "price_per_unit"
    t.decimal  "amount_used"
    t.boolean  "relevant_to_price",          default: true
    t.boolean  "is_from_solidarity_economy", default: false
    t.integer  "unit_id"
  end

  add_index "inputs", ["product_category_id"], name: "index_inputs_on_product_category_id", using: :btree
  add_index "inputs", ["product_id"], name: "index_inputs_on_product_id", using: :btree

  create_table "licenses", force: :cascade do |t|
    t.string  "name",           null: false
    t.string  "slug",           null: false
    t.string  "url"
    t.integer "environment_id", null: false
  end

  create_table "mailing_sents", force: :cascade do |t|
    t.integer  "mailing_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailings", force: :cascade do |t|
    t.string   "type"
    t.string   "subject"
    t.text     "body"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "person_id"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
  end

  create_table "national_region_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "national_regions", force: :cascade do |t|
    t.string   "name"
    t.string   "national_region_code"
    t.string   "parent_national_region_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "national_region_type_id"
  end

  add_index "national_regions", ["name"], name: "name_index", using: :btree
  add_index "national_regions", ["national_region_code"], name: "code_index", using: :btree

  create_table "price_details", force: :cascade do |t|
    t.decimal  "price",              default: 0.0
    t.integer  "product_id"
    t.integer  "production_cost_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_qualifiers", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "qualifier_id"
    t.integer  "certifier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_qualifiers", ["certifier_id"], name: "index_product_qualifiers_on_certifier_id", using: :btree
  add_index "product_qualifiers", ["product_id"], name: "index_product_qualifiers_on_product_id", using: :btree
  add_index "product_qualifiers", ["qualifier_id"], name: "index_product_qualifiers_on_qualifier_id", using: :btree

  create_table "production_costs", force: :cascade do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "product_category_id"
    t.string   "name"
    t.decimal  "price"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "discount"
    t.boolean  "available",           default: true
    t.boolean  "highlighted",         default: false
    t.integer  "unit_id"
    t.integer  "image_id"
    t.string   "type"
    t.text     "data"
    t.boolean  "archived",            default: false
  end

  add_index "products", ["created_at"], name: "index_products_on_created_at", using: :btree
  add_index "products", ["product_category_id"], name: "index_products_on_product_category_id", using: :btree
  add_index "products", ["profile_id"], name: "index_products_on_profile_id", using: :btree

  create_table "profile_activities", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "activity_id"
    t.string   "activity_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "profile_activities", ["activity_id", "activity_type"], name: "index_profile_activities_on_activity_id_and_activity_type", using: :btree
  add_index "profile_activities", ["activity_type"], name: "index_profile_activities_on_activity_type", using: :btree
  add_index "profile_activities", ["profile_id"], name: "index_profile_activities_on_profile_id", using: :btree

  create_table "profile_suggestions", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "suggestion_id"
    t.string   "suggestion_type"
    t.text     "categories"
    t.boolean  "enabled",         default: true
    t.float    "score",           default: 0.0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "profile_suggestions", ["person_id"], name: "index_profile_suggestions_on_person_id", using: :btree
  add_index "profile_suggestions", ["score"], name: "index_profile_suggestions_on_score", using: :btree
  add_index "profile_suggestions", ["suggestion_id"], name: "index_profile_suggestions_on_suggestion_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.string   "identifier"
    t.integer  "environment_id"
    t.boolean  "active",                             default: true
    t.string   "address"
    t.string   "contact_phone"
    t.integer  "home_page_id"
    t.integer  "user_id"
    t.integer  "region_id"
    t.text     "data"
    t.datetime "created_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "geocode_precision"
    t.boolean  "enabled",                            default: true
    t.string   "nickname",                limit: 16
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme"
    t.boolean  "public_profile",                     default: true
    t.date     "birth_date"
    t.integer  "preferred_domain_id"
    t.datetime "updated_at"
    t.boolean  "visible",                            default: true
    t.integer  "image_id"
    t.boolean  "validated",                          default: true
    t.string   "cnpj"
    t.string   "national_region_code"
    t.boolean  "is_template",                        default: false
    t.integer  "template_id"
    t.string   "redirection_after_login"
    t.integer  "friends_count",                      default: 0,     null: false
    t.integer  "members_count",                      default: 0,     null: false
    t.integer  "activities_count",                   default: 0,     null: false
    t.string   "personal_website"
    t.string   "jabber_id"
    t.integer  "welcome_page_id"
    t.boolean  "allow_members_to_invite",            default: true
    t.boolean  "invite_friends_only",                default: false
    t.boolean  "secret",                             default: false
  end

  add_index "profiles", ["activities_count"], name: "index_profiles_on_activities_count", using: :btree
  add_index "profiles", ["created_at"], name: "index_profiles_on_created_at", using: :btree
  add_index "profiles", ["environment_id"], name: "index_profiles_on_environment_id", using: :btree
  add_index "profiles", ["friends_count"], name: "index_profiles_on_friends_count", using: :btree
  add_index "profiles", ["identifier"], name: "index_profiles_on_identifier", using: :btree
  add_index "profiles", ["members_count"], name: "index_profiles_on_members_count", using: :btree
  add_index "profiles", ["region_id"], name: "index_profiles_on_region_id", using: :btree
  add_index "profiles", ["user_id", "type"], name: "index_profiles_on_user_id_and_type", using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "qualifier_certifiers", force: :cascade do |t|
    t.integer "qualifier_id"
    t.integer "certifier_id"
  end

  create_table "qualifiers", force: :cascade do |t|
    t.string   "name",           null: false
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refused_join_community", id: false, force: :cascade do |t|
    t.integer "person_id"
    t.integer "community_id"
  end

  create_table "region_validators", id: false, force: :cascade do |t|
    t.integer "region_id"
    t.integer "organization_id"
  end

  create_table "reported_images", force: :cascade do |t|
    t.integer "size"
    t.string  "content_type"
    t.string  "filename"
    t.integer "height"
    t.integer "width"
    t.integer "abuse_report_id"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer  "accessor_id",   null: false
    t.string   "accessor_type"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "role_id",       null: false
    t.boolean  "is_global"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string  "name"
    t.string  "key"
    t.boolean "system",         default: false
    t.text    "permissions"
    t.integer "environment_id"
    t.integer "profile_id"
  end

  create_table "scraps", force: :cascade do |t|
    t.text     "content"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "scrap_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "context_id"
  end

  create_table "search_term_occurrences", force: :cascade do |t|
    t.integer  "search_term_id"
    t.datetime "created_at"
    t.integer  "total",          default: 0
    t.integer  "indexed",        default: 0
  end

  add_index "search_term_occurrences", ["created_at"], name: "index_search_term_occurrences_on_created_at", using: :btree

  create_table "search_terms", force: :cascade do |t|
    t.string  "term"
    t.integer "context_id"
    t.string  "context_type"
    t.string  "asset",            default: "all"
    t.float   "score",            default: 0.0
    t.float   "relevance_score",  default: 0.0
    t.float   "occurrence_score", default: 0.0
  end

  add_index "search_terms", ["asset"], name: "index_search_terms_on_asset", using: :btree
  add_index "search_terms", ["occurrence_score"], name: "index_search_terms_on_occurrence_score", using: :btree
  add_index "search_terms", ["relevance_score"], name: "index_search_terms_on_relevance_score", using: :btree
  add_index "search_terms", ["score"], name: "index_search_terms_on_score", using: :btree
  add_index "search_terms", ["term"], name: "index_search_terms_on_term", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "suggestion_connections", force: :cascade do |t|
    t.integer "suggestion_id",   null: false
    t.integer "connection_id",   null: false
    t.string  "connection_type", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "parent_id"
    t.boolean "pending",        default: false
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["parent_id"], name: "index_tags_on_parent_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.text     "data"
    t.integer  "status"
    t.datetime "end_date"
    t.integer  "requestor_id"
    t.integer  "target_id"
    t.string   "code",           limit: 40
    t.string   "type"
    t.datetime "created_at"
    t.string   "target_type"
    t.integer  "image_id"
    t.boolean  "spam",                      default: false
    t.integer  "responsible_id"
    t.integer  "closed_by_id"
  end

  add_index "tasks", ["requestor_id"], name: "index_tasks_on_requestor_id", using: :btree
  add_index "tasks", ["spam"], name: "index_tasks_on_spam", using: :btree
  add_index "tasks", ["status"], name: "index_tasks_on_status", using: :btree
  add_index "tasks", ["target_id", "target_type"], name: "index_tasks_on_target_id_and_target_type", using: :btree
  add_index "tasks", ["target_id"], name: "index_tasks_on_target_id", using: :btree
  add_index "tasks", ["target_type"], name: "index_tasks_on_target_type", using: :btree

  create_table "terms_forum_people", id: false, force: :cascade do |t|
    t.integer "forum_id"
    t.integer "person_id"
  end

  add_index "terms_forum_people", ["forum_id", "person_id"], name: "index_terms_forum_people_on_forum_id_and_person_id", using: :btree

  create_table "thumbnails", force: :cascade do |t|
    t.integer "size"
    t.string  "content_type"
    t.string  "filename"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail"
  end

  add_index "thumbnails", ["parent_id"], name: "index_thumbnails_on_parent_id", using: :btree

  create_table "units", force: :cascade do |t|
    t.string  "singular",       null: false
    t.string  "plural",         null: false
    t.integer "position"
    t.integer "environment_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",           limit: 40
    t.string   "salt",                       limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "terms_of_use"
    t.string   "terms_accepted",             limit: 1
    t.integer  "environment_id"
    t.string   "password_type"
    t.boolean  "enable_email",                          default: false
    t.string   "last_chat_status",                      default: ""
    t.string   "chat_status",                           default: ""
    t.datetime "chat_status_at"
    t.string   "activation_code",            limit: 40
    t.datetime "activated_at"
    t.string   "return_to"
    t.datetime "last_login_at"
    t.string   "private_token"
    t.datetime "private_token_generated_at"
  end

  create_table "validation_infos", force: :cascade do |t|
    t.text    "validation_methodology"
    t.text    "restrictions"
    t.integer "organization_id"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "vote",          null: false
    t.integer  "voteable_id",   null: false
    t.string   "voteable_type", null: false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], name: "fk_voteables", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "fk_voters", using: :btree

end
