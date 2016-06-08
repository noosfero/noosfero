require "#{File.dirname(__FILE__)}/../test_helper"

class ElasticsearchTest < ActiveSupport::TestCase
  def setup
    start_cluster
    @environment = Environment.default
    @environment.enable_plugin(ElasticsearchPlugin)
    @profile = create_user('testing').person
  end

  def teardown
    stop_cluster
  end


  should ' be return yellow for health status' do
      cluster = Elasticsearch::Model.client.cluster
      assert_equal 'yellow', cluster.health["status"]
  end
end
