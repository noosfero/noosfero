# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 45) do

  create_table "article_versions", :force => true do |t|
    t.integer  "article_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slug"
    t.text     "path",               :default => ""
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
    t.boolean  "advertise",          :default => true
    t.boolean  "published",          :default => true
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "children_count",     :default => 0
  end

  create_table "articles", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "path",               :default => ""
    t.integer  "parent_id"
    t.text     "body"
    t.text     "abstract"
    t.integer  "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "last_changed_by_id"
    t.integer  "version"
    t.integer  "lock_version"
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "comments_count",     :default => 0
    t.boolean  "advertise",          :default => true
    t.boolean  "published",          :default => true
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "children_count",     :default => 0
  end

  create_table "articles_categories", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "category_id"
    t.boolean "virtual",     :default => false
  end

  add_index "articles_categories", ["article_id"], :name => "index_articles_categories_on_article_id"
  add_index "articles_categories", ["category_id"], :name => "index_articles_categories_on_category_id"

  create_table "blocks", :force => true do |t|
    t.string  "title"
    t.integer "box_id"
    t.string  "type"
    t.text    "settings"
    t.integer "position"
  end

  create_table "boxes", :force => true do |t|
    t.string  "owner_type"
    t.integer "owner_id"
    t.integer "position"
  end

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
  end

  create_table "categories_profiles", :id => false, :force => true do |t|
    t.integer "profile_id"
    t.integer "category_id"
    t.boolean "virtual",     :default => false
  end

  create_table "comments", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "article_id"
    t.integer  "author_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
  end

  create_table "consumptions", :force => true do |t|
    t.integer "product_category_id"
    t.integer "profile_id"
    t.text    "aditional_specifications"
  end

  create_table "domains", :force => true do |t|
    t.string  "name"
    t.string  "owner_type"
    t.integer "owner_id"
  end

  create_table "environments", :force => true do |t|
    t.string  "name"
    t.string  "contact_email"
    t.boolean "is_default"
    t.text    "settings"
    t.text    "design_data"
  end

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
  end

  create_table "product_categorizations", :force => true do |t|
    t.integer  "category_id"
    t.integer  "product_id"
    t.boolean  "virtual",     :default => false
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
  end

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "identifier"
    t.integer  "environment_id"
    t.boolean  "active",            :default => true
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
    t.boolean  "enabled",           :default => true
  end

  create_table "region_validators", :id => false, :force => true do |t|
    t.integer "region_id"
    t.integer "organization_id"
  end

  create_table "role_assignments", :force => true do |t|
    t.integer "accessor_id"
    t.string  "accessor_type"
    t.integer "resource_id"
    t.string  "resource_type"
    t.integer "role_id"
    t.boolean "is_global"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.string  "permissions"
    t.string  "key"
    t.boolean "system",      :default => false
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
  end

  create_table "validation_infos", :force => true do |t|
    t.text    "validation_methodology"
    t.text    "restrictions"
    t.integer "organization_id"
  end

end
