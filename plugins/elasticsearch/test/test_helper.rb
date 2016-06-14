require 'test_helper'

class ElasticsearchTestHelper < ActionController::TestCase

  def setup
    setup_environment
    import_instancies
  end

  def teardown
    indexed_models.each {|model|
      model.__elasticsearch__.client.indices.delete index: model.index_name
    }
  end

  def import_instancies
    indexed_models.each {|model|
      model.__elasticsearch__.create_index!
      model.import
    }
    sleep 2
  end

  def setup_environment
    @environment = Environment.default
    @environment.enable_plugin(ElasticsearchPlugin)
  end

  def indexed_models
    []
  end

  def indexed_fields model
    model.mappings.to_hash[model.name.downcase.to_sym][:properties]
  end

end
