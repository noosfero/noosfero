require "#{File.dirname(__FILE__)}/../test_helper"

class CommunityTest < ActiveSupport::TestCase
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
    community_cluster = Community.__elasticsearch__.client.cluster

    assert_not_nil Community.mappings.to_hash[:community][:properties][:name]
    assert_not_nil Community.mappings.to_hash[:community][:properties][:identifier]
    assert_not_nil Community.mappings.to_hash[:community][:properties][:nickname]
  end
end
