ActiveRecord::Schema.define(:version => 0) do

  create_table "nested_has_many_through_cities", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nested_has_many_through_countries", :force => true do |t|
    t.string   "name"
    t.integer  "planet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nested_has_many_through_planets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nested_has_many_through_pubs", :force => true do |t|
    t.string   "name"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
