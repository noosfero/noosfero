require_dependency 'enterprise'
require_dependency "#{File.dirname(__FILE__)}/profile"

class Enterprise
  after_save_reindex [:products], :with => :delayed_job
  solr_plugin_extra_data_for_index :product_categories
end
