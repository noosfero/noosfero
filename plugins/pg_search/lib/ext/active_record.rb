require_dependency 'active_record'

class ActiveRecord::Base
  def self.pg_search_plugin_search(query)
    filtered_query = query.gsub(/[\|\(\)\\\/\s\[\]'"*%&!:]/,' ').split.map{|w| w += ":*"}.join('|')
    if defined?(self::SEARCHABLE_FIELDS)
      where("to_tsvector('simple', #{pg_search_plugin_fields}) @@ to_tsquery('#{filtered_query}')")
    else
      raise "No searchable fields defined for #{self.name}"
    end
  end

  def self.pg_search_plugin_fields
    self::SEARCHABLE_FIELDS.keys.map(&:to_s).sort.map {|f| "coalesce(#{table_name}.#{f}, '')"}.join(" || ' ' || ")
  end
end
