require 'active_support/concern'

module PgSearchPlugin::SearchScope
  extend ActiveSupport::Concern

  PRIORITIES = {0 => 'A', 1 => 'B', 2 => 'C', 3 => 'D'}

  included do
    include PgSearch

    pg_search_scope :pg_search_plugin_search, -> query {
      { query: query, against: searchable_fields,
        using: {tsearch: {prefix: true}}
      }
    }

    # Use count
    scope :pg_search_plugin_attribute_facets, -> scope, attribute {
      where(id: scope.map(&:id)).
      group(attribute.to_sym).
      order('count_id DESC')
    }
  end

  class_methods do
    def searchable_fields
      if defined?(self::SEARCHABLE_FIELDS)
        i = 0
        self::SEARCHABLE_FIELDS.sort_by {|key,value| value[:weight]}.map {|item| item[0]}.reverse.inject({}) do |result, key|
          result[key] = PRIORITIES[i] || 'D'
          i += 1
          result
        end
      else
        []
      end
    end
  end
end
