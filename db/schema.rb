# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110524151137) do

  create_table "action_tracker", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.text     "params"
    t.string   "verb"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_tracker", ["target_id", "target_type"], :name => "index_action_tracker_on_dispatcher_id_and_dispatcher_type"
  add_index "action_tracker", ["user_id", "user_type"], :name => "index_action_tracker_on_user_id_and_user_type"
  add_index "action_tracker", ["verb"], :name => "index_action_tracker_on_verb"

  create_table "action_tracker_notifications", :force => true do |t|
    t.integer "action_tracker_id"
    t.integer "profile_id"
  end

  add_index "action_tracker_notifications", ["action_tracker_id"], :name => "index_action_tracker_notifications_on_action_tracker_id"
  add_index "action_tracker_notifications", ["profile_id", "action_tracker_id"], :name => "index_action_tracker_notifications_on_profile_id_and_action_tracker_id", :unique => true
  add_index "action_tracker_notifications", ["profile_id"], :name => "index_action_tracker_notifications_on_profile_id"

  create_table "article_versions", :force => true do |t|
    t.integer  "article_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slug"
    t.text     "path",                 :default => ""
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
    t.boolean  "advertise",            :default => true
    t.boolean  "published",            :default => true
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "children_count",       :default => 0
    t.boolean  "accept_comments",      :default => true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",      :default => false
    t.integer  "hits",                 :default => 0
    t.date     "published_at"
    t.string   "source"
    t.boolean  "highlighted",          :default => false
    t.string   "external_link"
    t.boolean  "thumbnails_processed", :default => false
    t.boolean  "is_image",             :default => false
    t.integer  "translation_of_id"
    t.string   "language"
    t.string   "source_name"
  end

  create_table "articles", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "path",                 :default => ""
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
    t.integer  "comments_count",       :default => 0
    t.boolean  "advertise",            :default => true
    t.boolean  "published",            :default => true
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "children_count",       :default => 0
    t.boolean  "accept_comments",      :default => true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",      :default => true
    t.integer  "hits",                 :default => 0
    t.date     "published_at"
    t.string   "source"
    t.boolean  "highlighted",          :default => false
    t.string   "external_link"
    t.boolean  "thumbnails_processed", :default => false
    t.boolean  "is_image",             :default => false
    t.integer  "translation_of_id"
    t.string   "language"
    t.string   "source_name"
  end

  add_index "articles", ["translation_of_id"], :name => "index_articles_on_translation_of_id"

  create_table "articles_categories", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "category_id"
    t.boolean "virtual",     :default => false
  end

  add_index "articles_categories", ["article_id"], :name => "index_articles_categories_on_article_id"
  add_index "articles_categories", ["category_id"], :name => "index_articles_categories_on_category_id"

  create_table "blocks", :force => true do |t|
    t.string   "title"
    t.integer  "box_id"
    t.string   "type"
    t.text     "settings"
    t.integer  "position"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fetched_at"
  end

  add_index "blocks", ["box_id"], :name => "index_blocks_on_box_id"
  add_index "blocks", ["enabled"], :name => "index_blocks_on_enabled"
  add_index "blocks", ["fetched_at"], :name => "index_blocks_on_fetched_at"
  add_index "blocks", ["type"], :name => "index_blocks_on_type"

  create_table "boxes", :force => true do |t|
    t.string  "owner_type"
    t.integer "owner_id"
    t.integer "position"
  end

  add_index "boxes", ["owner_id", "owner_type"], :name => "index_boxes_on_owner_type_and_owner_id"

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.string  "slug"
    t.text    "path",            :default => ""
    t.integer "display_color"
    t.integer "environment_id"
    t.integer "parent_id"
    t.string  "type"
    t.float   "lat"
    t.float   "lng"
    t.boolean "display_in_menu", :default => false
    t.integer "children_count",  :default => 0
    t.boolean "accept_products", :default => true
  end

  create_table "categories_profiles", :id => false, :force => true do |t|
    t.integer "profile_id"
    t.integer "category_id"
    t.boolean "virtual",     :default => false
  end

  add_index "categories_profiles", ["category_id"], :name => "index_categories_profiles_on_category_id"
  add_index "categories_profiles", ["profile_id"], :name => "index_categories_profiles_on_profile_id"

  create_table "certifiers", :force => true do |t|
    t.string   "name",           :null => false
    t.text     "description"
    t.string   "link"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "article_id"
    t.integer  "author_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.integer  "reply_of_id"
  end

  create_table "contact_lists", :force => true do |t|
    t.text     "list"
    t.string   "error_fetching"
    t.boolean  "fetched",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "domains", :force => true do |t|
    t.string  "name"
    t.string  "owner_type"
    t.integer "owner_id"
    t.boolean "is_default",      :default => false
    t.string  "google_maps_key"
  end

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.string   "contact_email"
    t.boolean  "is_default"
    t.text     "settings"
    t.text     "design_data"
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme",                        :default => "default", :null => false
    t.text     "terms_of_use_acceptance_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_feeds", :force => true do |t|
    t.string   "feed_title"
    t.datetime "fetched_at"
    t.string   "address"
    t.integer  "blog_id",                         :null => false
    t.boolean  "enabled",       :default => true, :null => false
    t.boolean  "only_once",     :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error_message"
    t.integer  "update_errors", :default => 0
  end

  add_index "external_feeds", ["enabled"], :name => "index_external_feeds_on_enabled"
  add_index "external_feeds", ["fetched_at"], :name => "index_external_feeds_on_fetched_at"

  create_table "favorite_enteprises_people", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "enterprise_id"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "person_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.string   "group"
  end

  create_table "images", :force => true do |t|
    t.string  "owner_type"
    t.integer "owner_id"
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "thumbnails_processed", :default => false
  end

  create_table "inputs", :force => true do |t|
    t.integer  "product_id",                                    :null => false
    t.integer  "product_category_id",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.decimal  "price_per_unit"
    t.decimal  "amount_used"
    t.boolean  "relevant_to_price",          :default => true
    t.boolean  "is_from_solidarity_economy", :default => false
    t.integer  "unit_id"
  end

  create_table "mailing_sents", :force => true do |t|
    t.integer  "mailing_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailings", :force => true do |t|
    t.string   "type"
    t.string   "subject"
    t.text     "body"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "person_id"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_categorizations", :force => true do |t|
    t.integer  "category_id"
    t.integer  "product_id"
    t.boolean  "virtual",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_categorizations", ["category_id"], :name => "index_product_categorizations_on_category_id"
  add_index "product_categorizations", ["product_id"], :name => "index_product_categorizations_on_product_id"

  create_table "product_qualifiers", :force => true do |t|
    t.integer  "product_id"
    t.integer  "qualifier_id"
    t.integer  "certifier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "enterprise_id"
    t.integer  "product_category_id"
    t.string   "name"
    t.decimal  "price"
    t.text     "description"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "lng"
    t.decimal  "discount"
    t.boolean  "available",           :default => true
    t.boolean  "highlighted"
    t.integer  "unit_id"
  end

  add_index "products", ["enterprise_id"], :name => "index_products_on_enterprise_id"

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "identifier"
    t.integer  "environment_id"
    t.boolean  "active",                            :default => true
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
    t.boolean  "enabled",                           :default => true
    t.string   "nickname",            :limit => 16
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme"
    t.boolean  "public_profile",                    :default => true
    t.date     "birth_date"
    t.integer  "preferred_domain_id"
    t.datetime "updated_at"
    t.boolean  "visible",                           :default => true
  end

  add_index "profiles", ["environment_id"], :name => "index_profiles_on_environment_id"

  create_table "qualifier_certifiers", :force => true do |t|
    t.integer "qualifier_id"
    t.integer "certifier_id"
  end

  create_table "qualifiers", :force => true do |t|
    t.string   "name",           :null => false
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refused_join_community", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "community_id"
  end

  create_table "region_validators", :id => false, :force => true do |t|
    t.integer "region_id"
    t.integer "organization_id"
  end

  create_table "role_assignments", :force => true do |t|
    t.integer "accessor_id",   :null => false
    t.string  "accessor_type"
    t.integer "resource_id"
    t.string  "resource_type"
    t.integer "role_id",       :null => false
    t.boolean "is_global"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.string  "key"
    t.boolean "system",         :default => false
    t.text    "permissions"
    t.integer "environment_id"
  end

  create_table "scraps", :force => true do |t|
    t.text     "content"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "scrap_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.boolean "pending",   :default => false
  end

  create_table "tasks", :force => true do |t|
    t.text     "data"
    t.integer  "status"
    t.date     "end_date"
    t.integer  "requestor_id"
    t.integer  "target_id"
    t.string   "code",         :limit => 40
    t.string   "type"
    t.datetime "created_at"
    t.string   "target_type"
  end

  create_table "thumbnails", :force => true do |t|
    t.integer "size"
    t.string  "content_type"
    t.string  "filename"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail"
  end

  create_table "units", :force => true do |t|
    t.string  "singular",       :null => false
    t.string  "plural",         :null => false
    t.integer "position"
    t.integer "environment_id", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "terms_of_use"
    t.string   "terms_accepted",            :limit => 1
    t.integer  "environment_id"
    t.string   "password_type"
    t.boolean  "enable_email",                            :default => false
    t.string   "last_chat_status",                        :default => ""
    t.string   "chat_status",                             :default => ""
    t.datetime "chat_status_at"
  end

  create_table "validation_infos", :force => true do |t|
    t.text    "validation_methodology"
    t.text    "restrictions"
    t.integer "organization_id"
  end

end
