require 'active_record'

class ActiveRecord::Base

  def self.postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end

  alias :meta_cache_key :cache_key
  def cache_key
    key = [Noosfero::VERSION, meta_cache_key]
    key.unshift(ActiveRecord::Base.connection.schema_search_path) if ActiveRecord::Base.postgresql?
    key.join('/')
  end

  def self.like_search(query)
    if defined?(self::SEARCHABLE_FIELDS)
      fields = self::SEARCHABLE_FIELDS.keys.map(&:to_s) & column_names
      query = query.downcase.strip
      conditions = fields.map do |field|
        "lower(#{table_name}.#{field}) LIKE '%#{query}%'"
      end.join(' OR ')
      where(conditions)
    else
      raise "No searchable fields defined for #{self.name}"
    end
  end

end

ActiveRecord::Calculations.module_eval do
  def count_with_default_distinct(column_name=:id, options={})
    count_without_default_distinct(column_name, {:distinct => true}.merge(options))
  end
  alias_method_chain :count, :default_distinct
end
