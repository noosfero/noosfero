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

ActiveRecord::Schema.define(version: 20181024151736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuse_reports", force: :cascade do |t|
    t.integer "reporter_id"
    t.integer "abuse_complaint_id"
    t.text "content"
    t.text "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "action_tracker", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_type"
    t.integer "target_id"
    t.string "target_type"
    t.text "params"
    t.string "verb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "comments_count", default: 0
    t.boolean "visible", default: true
    t.index ["target_id", "target_type"], name: "index_action_tracker_on_dispatcher_id_and_dispatcher_type"
    t.index ["user_id", "user_type"], name: "index_action_tracker_on_user_id_and_user_type"
    t.index ["verb"], name: "index_action_tracker_on_verb"
  end

  create_table "action_tracker_notifications", force: :cascade do |t|
    t.integer "action_tracker_id"
    t.integer "profile_id"
    t.index ["action_tracker_id"], name: "index_action_tracker_notifications_on_action_tracker_id"
    t.index ["profile_id", "action_tracker_id"], name: "index_action_tracker_notif_on_prof_id_act_tracker_id", unique: true
    t.index ["profile_id"], name: "index_action_tracker_notifications_on_profile_id"
  end

  create_table "article_followers", force: :cascade do |t|
    t.integer "person_id"
    t.integer "article_id"
    t.datetime "since"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["article_id"], name: "index_article_followers_on_article_id"
    t.index ["person_id", "article_id"], name: "index_article_followers_on_person_id_and_article_id", unique: true
    t.index ["person_id"], name: "index_article_followers_on_person_id"
  end

  create_table "article_privacy_exceptions", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "person_id"
  end

  create_table "article_versions", force: :cascade do |t|
    t.integer "article_id"
    t.integer "version"
    t.string "name"
    t.string "slug"
    t.text "path", default: ""
    t.integer "parent_id"
    t.text "body"
    t.text "abstract"
    t.integer "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer "last_changed_by_id"
    t.integer "size"
    t.string "content_type"
    t.string "filename"
    t.integer "height"
    t.integer "width"
    t.string "versioned_type"
    t.integer "comments_count"
    t.boolean "advertise", default: true
    t.boolean "published", default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "children_count", default: 0
    t.boolean "accept_comments", default: true
    t.integer "reference_article_id"
    t.text "setting"
    t.boolean "notify_comments", default: false
    t.integer "hits", default: 0
    t.datetime "published_at"
    t.string "source"
    t.boolean "highlighted", default: false
    t.string "external_link"
    t.boolean "thumbnails_processed", default: false
    t.boolean "is_image", default: false
    t.integer "translation_of_id"
    t.string "language"
    t.string "source_name"
    t.integer "license_id"
    t.integer "image_id"
    t.integer "position"
    t.integer "spam_comments_count", default: 0
    t.integer "author_id"
    t.integer "created_by_id"
    t.index ["article_id"], name: "index_article_versions_on_article_id"
    t.index ["parent_id"], name: "index_article_versions_on_parent_id"
    t.index ["path", "profile_id"], name: "index_article_versions_on_path_and_profile_id"
    t.index ["path"], name: "index_article_versions_on_path"
    t.index ["published_at", "id"], name: "index_article_versions_on_published_at_and_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "path", default: ""
    t.integer "parent_id"
    t.text "body"
    t.text "abstract"
    t.integer "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer "last_changed_by_id"
    t.integer "version"
    t.string "type"
    t.integer "size"
    t.string "content_type"
    t.string "filename"
    t.integer "height"
    t.integer "width"
    t.integer "comments_count", default: 0
    t.boolean "advertise", default: true
    t.boolean "published", default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "children_count", default: 0
    t.boolean "accept_comments", default: true
    t.integer "reference_article_id"
    t.text "setting"
    t.boolean "notify_comments", default: true
    t.integer "hits", default: 0
    t.datetime "published_at"
    t.string "source"
    t.boolean "highlighted", default: false
    t.string "external_link"
    t.boolean "thumbnails_processed", default: false
    t.boolean "is_image", default: false
    t.integer "translation_of_id"
    t.string "language"
    t.string "source_name"
    t.integer "license_id"
    t.integer "image_id"
    t.integer "position", default: 0
    t.integer "spam_comments_count", default: 0
    t.integer "author_id"
    t.integer "created_by_id"
    t.boolean "show_to_followers", default: true
    t.integer "followers_count", default: 0
    t.boolean "archived", default: false
    t.string "editor", default: "tiny_mce", null: false
    t.jsonb "metadata", default: {}
    t.integer "access", default: 0
    t.index ["comments_count"], name: "index_articles_on_comments_count"
    t.index ["created_at"], name: "index_articles_on_created_at"
    t.index ["hits"], name: "index_articles_on_hits"
    t.index ["metadata"], name: "index_articles_on_metadata", using: :gin
    t.index ["name"], name: "index_articles_on_name"
    t.index ["parent_id"], name: "index_articles_on_parent_id"
    t.index ["path", "profile_id"], name: "index_articles_on_path_and_profile_id"
    t.index ["path"], name: "index_articles_on_path"
    t.index ["profile_id"], name: "index_articles_on_profile_id"
    t.index ["published_at", "id"], name: "index_articles_on_published_at_and_id"
    t.index ["slug"], name: "index_articles_on_slug"
    t.index ["translation_of_id"], name: "index_articles_on_translation_of_id"
    t.index ["type", "parent_id"], name: "index_articles_on_type_and_parent_id"
    t.index ["type", "profile_id"], name: "index_articles_on_type_and_profile_id"
    t.index ["type"], name: "index_articles_on_type"
  end

  create_table "articles_categories", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "category_id"
    t.boolean "virtual", default: false
    t.index ["article_id"], name: "index_articles_categories_on_article_id"
    t.index ["category_id"], name: "index_articles_categories_on_category_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.string "title"
    t.integer "box_id"
    t.string "type"
    t.text "settings"
    t.integer "position"
    t.boolean "enabled", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fetched_at"
    t.boolean "mirror", default: false
    t.integer "mirror_block_id"
    t.integer "observers_id"
    t.string "subtitle", default: ""
    t.jsonb "metadata", default: {}
    t.string "css"
    t.index ["box_id"], name: "index_blocks_on_box_id"
    t.index ["enabled"], name: "index_blocks_on_enabled"
    t.index ["fetched_at"], name: "index_blocks_on_fetched_at"
    t.index ["metadata"], name: "index_blocks_on_metadata", using: :gin
    t.index ["type"], name: "index_blocks_on_type"
  end

  create_table "boxes", force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.integer "position"
    t.index ["owner_id", "owner_type"], name: "index_boxes_on_owner_type_and_owner_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "path", default: ""
    t.integer "environment_id"
    t.integer "parent_id"
    t.string "type", default: "Category"
    t.float "lat"
    t.float "lng"
    t.boolean "display_in_menu", default: false
    t.integer "children_count", default: 0
    t.boolean "accept_products", default: true
    t.integer "image_id"
    t.string "acronym"
    t.string "abbreviation"
    t.string "display_color", limit: 6
    t.text "ancestry"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "categories_profiles", id: false, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "category_id"
    t.boolean "virtual", default: false
    t.index ["category_id"], name: "index_categories_profiles_on_category_id"
    t.index ["profile_id"], name: "index_categories_profiles_on_profile_id"
  end

  create_table "certifiers", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "link"
    t.integer "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_chat_messages_on_created_at"
    t.index ["from_id"], name: "index_chat_messages_on_from_id"
    t.index ["to_id"], name: "index_chat_messages_on_to_id"
  end

  create_table "circles", force: :cascade do |t|
    t.string "name"
    t.integer "person_id"
    t.string "profile_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id", "name", "profile_type"], name: "circles_composite_key_index", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "source_id"
    t.integer "author_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.integer "reply_of_id"
    t.string "ip_address"
    t.boolean "spam"
    t.string "source_type"
    t.string "user_agent"
    t.string "referrer"
    t.text "settings"
    t.jsonb "metadata", default: {}
    t.index ["metadata"], name: "index_comments_on_metadata", using: :gin
    t.index ["source_id", "spam"], name: "index_comments_on_source_id_and_spam"
  end

  create_table "contact_lists", force: :cascade do |t|
    t.text "list"
    t.string "error_fetching"
    t.boolean "fetched", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.string "customized_type", default: "", null: false
    t.integer "customized_id", default: 0, null: false
    t.boolean "public", default: false, null: false
    t.integer "custom_field_id", default: 0, null: false
    t.text "value", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["customized_type", "customized_id", "custom_field_id"], name: "index_custom_field_values", unique: true
  end

  create_table "custom_fields", force: :cascade do |t|
    t.string "name"
    t.string "format", default: ""
    t.text "default_value", default: ""
    t.string "customized_type"
    t.text "extras", default: ""
    t.boolean "active", default: false
    t.boolean "required", default: false
    t.boolean "signup", default: false
    t.integer "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "moderation_task", default: false
    t.index ["customized_type", "name", "environment_id"], name: "index_custom_field", unique: true
  end

  create_table "custom_forms_plugin_alternatives", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "field_id"
    t.boolean "selected_by_default", default: false, null: false
    t.integer "position", default: 0
  end

  create_table "custom_forms_plugin_answers", id: :serial, force: :cascade do |t|
    t.text "value"
    t.integer "field_id"
    t.integer "submission_id"
    t.boolean "imported", default: false
  end

  create_table "custom_forms_plugin_fields", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "type"
    t.string "default_value"
    t.float "minimum"
    t.float "maximum"
    t.integer "form_id"
    t.boolean "mandatory", default: false
    t.integer "position", default: 0
    t.string "show_as"
  end

  create_table "custom_forms_plugin_form_answers", id: :serial, force: :cascade do |t|
    t.integer "alternative_id"
    t.integer "answer_id"
    t.index ["alternative_id"], name: "index_custom_forms_plugin_form_answers_on_alternative_id"
    t.index ["answer_id"], name: "index_custom_forms_plugin_form_answers_on_answer_id"
  end

  create_table "custom_forms_plugin_forms", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.integer "profile_id"
    t.datetime "begining"
    t.datetime "ending"
    t.boolean "report_submissions", default: false
    t.boolean "on_membership", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "for_admission", default: false
    t.integer "article_id"
    t.string "kind", default: "survey"
    t.string "identifier"
    t.string "access_result_options", default: "public"
    t.integer "access", default: 0
  end

  create_table "custom_forms_plugin_submissions", id: :serial, force: :cascade do |t|
    t.string "author_name"
    t.string "author_email"
    t.integer "profile_id"
    t.integer "form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name"
    t.string "owner_type"
    t.integer "owner_id"
    t.boolean "is_default", default: false
    t.string "google_maps_key"
    t.index ["is_default"], name: "index_domains_on_is_default"
    t.index ["name"], name: "index_domains_on_name"
    t.index ["owner_id", "owner_type", "is_default"], name: "index_domains_on_owner_id_and_owner_type_and_is_default"
    t.index ["owner_id", "owner_type"], name: "index_domains_on_owner_id_and_owner_type"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name"
    t.string "template_type"
    t.string "subject"
    t.text "body"
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "environments", force: :cascade do |t|
    t.string "name"
    t.string "contact_email"
    t.boolean "is_default"
    t.text "settings"
    t.text "design_data"
    t.text "custom_header"
    t.text "custom_footer"
    t.string "theme", default: "default", null: false
    t.text "terms_of_use_acceptance_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "reports_lower_bound", default: 0, null: false
    t.string "redirection_after_login", default: "keep_on_same_page"
    t.text "signup_welcome_text"
    t.string "languages"
    t.string "default_language"
    t.string "noreply_email"
    t.string "redirection_after_signup", default: "keep_on_same_page"
    t.string "date_format", default: "month_name_with_year"
    t.boolean "enable_feed_proxy", default: false
    t.string "http_feed_proxy"
    t.string "https_feed_proxy"
    t.boolean "disable_feed_ssl", default: false
    t.jsonb "metadata", default: {}
    t.index ["metadata"], name: "index_environments_on_metadata", using: :gin
  end

  create_table "event_invitations", force: :cascade do |t|
    t.integer "event_id"
    t.integer "guest_id"
    t.integer "requestor_id"
    t.integer "decision"
  end

  create_table "external_feeds", force: :cascade do |t|
    t.string "feed_title"
    t.datetime "fetched_at"
    t.text "address"
    t.integer "blog_id", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "only_once", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "error_message"
    t.integer "update_errors", default: 0
    t.index ["blog_id"], name: "index_external_feeds_on_blog_id"
    t.index ["enabled"], name: "index_external_feeds_on_enabled"
    t.index ["fetched_at"], name: "index_external_feeds_on_fetched_at"
  end

  create_table "favorite_enterprise_people", force: :cascade do |t|
    t.integer "person_id"
    t.integer "enterprise_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["enterprise_id"], name: "index_favorite_enterprise_people_on_enterprise_id"
    t.index ["person_id", "enterprise_id"], name: "index_favorite_enterprise_people_on_person_id_and_enterprise_id"
    t.index ["person_id"], name: "index_favorite_enterprise_people_on_person_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "person_id"
    t.integer "friend_id"
    t.datetime "created_at"
    t.string "group"
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["person_id", "friend_id"], name: "index_friendships_on_person_id_and_friend_id"
    t.index ["person_id"], name: "index_friendships_on_person_id"
  end

  create_table "images", force: :cascade do |t|
    t.integer "parent_id"
    t.string "content_type"
    t.string "filename"
    t.string "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "thumbnails_processed", default: false
    t.string "label", default: ""
    t.integer "owner_id"
    t.string "owner_type"
    t.index ["owner_type", "owner_id"], name: "index_images_on_owner_type_and_owner_id"
    t.index ["parent_id"], name: "index_images_on_parent_id"
  end

  create_table "inputs", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "product_category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.decimal "price_per_unit"
    t.decimal "amount_used"
    t.boolean "relevant_to_price", default: true
    t.boolean "is_from_solidarity_economy", default: false
    t.integer "unit_id"
    t.index ["product_category_id"], name: "index_inputs_on_product_category_id"
    t.index ["product_id"], name: "index_inputs_on_product_id"
  end

  create_table "kinds", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.boolean "moderated", default: false
    t.integer "environment_id"
    t.jsonb "metadata", default: {}
    t.string "upload_quota"
  end

  create_table "kinds_profiles", force: :cascade do |t|
    t.integer "kind_id"
    t.integer "profile_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "url"
    t.integer "environment_id", null: false
  end

  create_table "mailing_sents", force: :cascade do |t|
    t.integer "mailing_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailings", force: :cascade do |t|
    t.string "type"
    t.string "subject"
    t.text "body"
    t.integer "source_id"
    t.string "source_type"
    t.integer "person_id"
    t.string "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "data"
  end

  create_table "national_region_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "national_regions", force: :cascade do |t|
    t.string "name"
    t.string "national_region_code"
    t.string "parent_national_region_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "national_region_type_id"
    t.index ["name"], name: "name_index"
    t.index ["national_region_code"], name: "code_index"
  end

  create_table "price_details", force: :cascade do |t|
    t.decimal "price", default: "0.0"
    t.integer "product_id"
    t.integer "production_cost_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "private_scraps", force: :cascade do |t|
    t.integer "person_id"
    t.integer "scrap_id"
  end

  create_table "product_qualifiers", force: :cascade do |t|
    t.integer "product_id"
    t.integer "qualifier_id"
    t.integer "certifier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["certifier_id"], name: "index_product_qualifiers_on_certifier_id"
    t.index ["product_id"], name: "index_product_qualifiers_on_product_id"
    t.index ["qualifier_id"], name: "index_product_qualifiers_on_qualifier_id"
  end

  create_table "production_costs", force: :cascade do |t|
    t.string "name"
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "product_category_id"
    t.string "name"
    t.decimal "price"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "discount"
    t.boolean "available", default: true
    t.boolean "highlighted", default: false
    t.integer "unit_id"
    t.integer "image_id"
    t.string "type"
    t.text "data"
    t.boolean "archived", default: false
    t.index ["created_at"], name: "index_products_on_created_at"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["profile_id"], name: "index_products_on_profile_id"
  end

  create_table "profile_activities", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "activity_id"
    t.string "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "activity_type"], name: "index_profile_activities_on_activity_id_and_activity_type"
    t.index ["activity_type"], name: "index_profile_activities_on_activity_type"
    t.index ["profile_id"], name: "index_profile_activities_on_profile_id"
  end

  create_table "profile_suggestions", force: :cascade do |t|
    t.integer "person_id"
    t.integer "suggestion_id"
    t.string "suggestion_type"
    t.text "categories"
    t.boolean "enabled", default: true
    t.float "score", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_profile_suggestions_on_person_id"
    t.index ["score"], name: "index_profile_suggestions_on_score"
    t.index ["suggestion_id"], name: "index_profile_suggestions_on_suggestion_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.string "identifier"
    t.integer "environment_id"
    t.boolean "active", default: true
    t.string "address"
    t.string "contact_phone"
    t.integer "home_page_id"
    t.integer "user_id"
    t.integer "region_id"
    t.text "data"
    t.datetime "created_at"
    t.float "lat"
    t.float "lng"
    t.integer "geocode_precision"
    t.boolean "enabled", default: true
    t.string "nickname", limit: 16
    t.text "custom_header"
    t.text "custom_footer"
    t.string "theme"
    t.date "birth_date"
    t.integer "preferred_domain_id"
    t.datetime "updated_at"
    t.boolean "visible", default: true
    t.integer "image_id"
    t.boolean "validated", default: true
    t.string "cnpj"
    t.string "national_region_code"
    t.boolean "is_template", default: false
    t.integer "template_id"
    t.string "redirection_after_login"
    t.integer "friends_count", default: 0, null: false
    t.integer "members_count", default: 0, null: false
    t.integer "activities_count", default: 0, null: false
    t.string "personal_website"
    t.string "jabber_id"
    t.integer "welcome_page_id"
    t.boolean "allow_members_to_invite", default: true
    t.boolean "invite_friends_only", default: false
    t.boolean "secret", default: false
    t.string "editor", default: "tiny_mce", null: false
    t.integer "top_image_id"
    t.jsonb "metadata", default: {}
    t.string "upload_quota"
    t.float "disk_usage"
    t.string "cropped_image"
    t.integer "access", default: 0
    t.index ["activities_count"], name: "index_profiles_on_activities_count"
    t.index ["created_at"], name: "index_profiles_on_created_at"
    t.index ["environment_id"], name: "index_profiles_on_environment_id"
    t.index ["friends_count"], name: "index_profiles_on_friends_count"
    t.index ["identifier"], name: "index_profiles_on_identifier"
    t.index ["members_count"], name: "index_profiles_on_members_count"
    t.index ["metadata"], name: "index_profiles_on_metadata", using: :gin
    t.index ["region_id"], name: "index_profiles_on_region_id"
    t.index ["user_id", "type"], name: "index_profiles_on_user_id_and_type"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "profiles_circles", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "circle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["profile_id", "circle_id"], name: "profiles_circles_composite_key_index", unique: true
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "endpoint", null: false
    t.jsonb "keys", default: {}, null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.integer "environment_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qualifier_certifiers", force: :cascade do |t|
    t.integer "qualifier_id"
    t.integer "certifier_id"
  end

  create_table "qualifiers", force: :cascade do |t|
    t.string "name", null: false
    t.integer "environment_id"
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
    t.string "content_type"
    t.string "filename"
    t.integer "height"
    t.integer "width"
    t.integer "abuse_report_id"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer "accessor_id", null: false
    t.string "accessor_type"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "role_id", null: false
    t.boolean "is_global"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.boolean "system", default: false
    t.text "permissions"
    t.integer "environment_id"
    t.integer "profile_id"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound", default: "default"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "alert_is_json", default: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false
    t.text "notification"
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "scraps", force: :cascade do |t|
    t.text "content"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.integer "scrap_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "context_id"
  end

  create_table "search_term_occurrences", force: :cascade do |t|
    t.integer "search_term_id"
    t.datetime "created_at"
    t.integer "total", default: 0
    t.integer "indexed", default: 0
    t.index ["created_at"], name: "index_search_term_occurrences_on_created_at"
  end

  create_table "search_terms", force: :cascade do |t|
    t.string "term"
    t.integer "context_id"
    t.string "context_type"
    t.string "asset", default: "all"
    t.float "score", default: 0.0
    t.float "relevance_score", default: 0.0
    t.float "occurrence_score", default: 0.0
    t.index ["asset"], name: "index_search_terms_on_asset"
    t.index ["occurrence_score"], name: "index_search_terms_on_occurrence_score"
    t.index ["relevance_score"], name: "index_search_terms_on_relevance_score"
    t.index ["score"], name: "index_search_terms_on_score"
    t.index ["term"], name: "index_search_terms_on_term"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "suggestion_connections", force: :cascade do |t|
    t.integer "suggestion_id", null: false
    t.integer "connection_id", null: false
    t.string "connection_type", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.datetime "created_at"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.boolean "pending", default: false
    t.integer "taggings_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["parent_id"], name: "index_tags_on_parent_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.text "data"
    t.integer "status"
    t.datetime "end_date"
    t.integer "requestor_id"
    t.integer "target_id"
    t.string "code", limit: 40
    t.string "type"
    t.datetime "created_at"
    t.string "target_type"
    t.integer "image_id"
    t.boolean "spam", default: false
    t.integer "responsible_id"
    t.integer "closed_by_id"
    t.jsonb "metadata", default: {}
    t.index ["metadata"], name: "index_tasks_on_metadata", using: :gin
    t.index ["requestor_id"], name: "index_tasks_on_requestor_id"
    t.index ["spam"], name: "index_tasks_on_spam"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["target_id", "target_type"], name: "index_tasks_on_target_id_and_target_type"
    t.index ["target_id"], name: "index_tasks_on_target_id"
    t.index ["target_type"], name: "index_tasks_on_target_type"
  end

  create_table "terms_forum_people", id: false, force: :cascade do |t|
    t.integer "forum_id"
    t.integer "person_id"
    t.index ["forum_id", "person_id"], name: "index_terms_forum_people_on_forum_id_and_person_id"
  end

  create_table "thumbnails", force: :cascade do |t|
    t.integer "size"
    t.string "content_type"
    t.string "filename"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string "thumbnail"
    t.index ["parent_id"], name: "index_thumbnails_on_parent_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "singular", null: false
    t.string "plural", null: false
    t.integer "position"
    t.integer "environment_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.text "terms_of_use"
    t.string "terms_accepted", limit: 1
    t.integer "environment_id"
    t.string "password_type"
    t.boolean "enable_email", default: false
    t.string "last_chat_status", default: ""
    t.string "chat_status", default: ""
    t.datetime "chat_status_at"
    t.string "activation_code", limit: 40
    t.datetime "activated_at"
    t.string "return_to"
    t.datetime "last_login_at"
    t.string "private_token"
    t.datetime "private_token_generated_at"
    t.jsonb "metadata", default: {}
    t.index ["metadata"], name: "index_users_on_metadata", using: :gin
  end

  create_table "validation_infos", force: :cascade do |t|
    t.text "validation_methodology"
    t.text "restrictions"
    t.integer "organization_id"
  end

  create_table "votes", force: :cascade do |t|
    t.integer "vote", null: false
    t.integer "voteable_id", null: false
    t.string "voteable_type", null: false
    t.integer "voter_id"
    t.string "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["voteable_id", "voteable_type"], name: "fk_voteables"
    t.index ["voter_id", "voter_type"], name: "fk_voters"
  end

  add_foreign_key "profiles_circles", "circles", on_delete: :cascade

  create_view "profile_access_friendships",  sql_definition: <<-SQL
      SELECT profiles.id,
      profiles.access,
      friendships.friend_id,
      friendships.person_id
     FROM (profiles
       LEFT JOIN friendships ON (((profiles.id = friendships.person_id) OR (profiles.id = friendships.friend_id))))
    WHERE (profiles.access > 10);
  SQL

  create_view "profile_access_memberships",  sql_definition: <<-SQL
      SELECT profiles.id,
      profiles.access,
      role_assignments.accessor_id AS member_id,
      roles.permissions,
      roles.key
     FROM ((profiles
       LEFT JOIN role_assignments ON ((profiles.id = role_assignments.resource_id)))
       LEFT JOIN roles ON ((role_assignments.role_id = roles.id)))
    WHERE (profiles.access > 10);
  SQL

  create_view "article_access_friendships",  sql_definition: <<-SQL
      SELECT articles.id,
      articles.profile_id,
      articles.access,
      friendships.friend_id,
      friendships.person_id
     FROM ((articles
       JOIN profiles ON ((profiles.id = articles.profile_id)))
       LEFT JOIN friendships ON (((articles.profile_id = friendships.person_id) OR (articles.profile_id = friendships.friend_id))))
    WHERE (articles.access > 10);
  SQL

  create_view "article_access_memberships",  sql_definition: <<-SQL
      SELECT articles.id,
      articles.profile_id,
      articles.access,
      role_assignments.accessor_id AS member_id,
      roles.permissions,
      roles.key
     FROM ((articles
       LEFT JOIN role_assignments ON ((articles.profile_id = role_assignments.resource_id)))
       LEFT JOIN roles ON ((role_assignments.role_id = roles.id)))
    WHERE (articles.access > 10);
  SQL

end
