require_dependency 'active_record'

class ActiveRecord::Base
  def self.pg_search_plugin_search(query)
    if defined?(self::SEARCHABLE_FIELDS)
      conditions = self::SEARCHABLE_FIELDS.map {|field, weight| "to_tsvector('simple', #{field}) @@ '#{query}'"}.join(' OR ')
      where(conditions)
    else
      raise "No searchable fields defined for #{self.name}"
    end
  end
end
