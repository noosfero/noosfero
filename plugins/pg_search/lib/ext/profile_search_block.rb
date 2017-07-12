require 'profile_search_block'
require_dependency 'pg_search_plugin/search_helper'

class ProfileSearchBlock

  extend PgSearchPlugin::SearchHelper

  attr_accessible :advanced_search, :search_fields
  settings_items :advanced_search, type: :boolean, default: false
  settings_items :search_fields, type: :Array, default: default_search_fields.map { |search_field| search_field_identifier(*search_field) }

  before_save { self.search_fields.delete("0") }

end
