require_dependency 'active_record'

class ActiveRecord::Base
  def self.pg_search_plugin_search(query)
    query.gsub!(/\|/,' ')
    formatted_query = query.split.map{|w| w += ":*"}.join('|')
    
    if defined?(self::SEARCHABLE_FIELDS)
      where("to_tsvector('simple', #{pg_search_plugin_fields}) @@ to_tsquery('#{formatted_query}')")
    else
      raise "No searchable fields defined for #{self.name}"
    end
  end

  def self.pg_search_plugin_fields
    self::SEARCHABLE_FIELDS.keys.map(&:to_s).sort.map {|f| "coalesce(#{table_name}.#{f}, '')"}.join(" || ' ' || ")
  end
end
