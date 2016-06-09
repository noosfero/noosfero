require "#{File.dirname(__FILE__)}/../test_helper"

class PersonTest < ActiveSupport::TestCase
  def setup
    start_cluster
    @environment = Environment.default
    @environment.enable_plugin(ElasticsearchPlugin)
    @profile = create_user('testing').person
  end

  def teardown
    stop_cluster
  end

  should 'index custom fields for Event model' do
    person_cluster = Person.__elasticsearch__.client.cluster

    assert_not_nil Person.mappings.to_hash[:person][:properties][:name]
    assert_not_nil Person.mappings.to_hash[:person][:properties][:identifier]
    assert_not_nil Person.mappings.to_hash[:person][:properties][:nickname]
    assert_not_nil Person.mappings.to_hash[:person][:properties][:visible]
  end

end
