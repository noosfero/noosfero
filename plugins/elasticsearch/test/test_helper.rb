require 'test_helper'
require_relative '../../../test/api/test_helper.rb'

module ElasticsearchTestHelper

  def setup
    setup_environment
    create_instances
    import_instancies
  end

  def create_instances
  end

  def teardown
    indexed_models.each {|model|
      model.__elasticsearch__.client.indices.delete index: model.index_name
    }
  end

  def import_instancies
    indexed_models.each {|model|
      model.__elasticsearch__.create_index!
      sleep 2
      model.import
      sleep 1
    }
  end

  def setup_environment
    @environment = Environment.default
    @environment.enable_plugin(ElasticsearchPlugin)
  end

  def indexed_models
    []
  end

  def indexed_fields model
    model.mappings.to_hash[model.name.underscore.to_sym][:properties]
  end

end
