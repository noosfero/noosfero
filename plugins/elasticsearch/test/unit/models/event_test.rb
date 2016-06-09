require "#{File.dirname(__FILE__)}/../test_helper"

class EventTest < ActiveSupport::TestCase
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
    event_cluster = Event.__elasticsearch__.client.cluster

    assert_not_nil Event.mappings.to_hash[:event][:properties][:advertise]
    assert_not_nil Event.mappings.to_hash[:event][:properties][:published]
  end
end
