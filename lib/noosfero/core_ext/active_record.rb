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

end
