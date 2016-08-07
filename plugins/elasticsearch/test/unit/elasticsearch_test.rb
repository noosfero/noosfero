require "#{File.dirname(__FILE__)}/../test_helper"

class ElasticsearchTest < ActionController::TestCase

  should 'be return yellow for health status' do
      cluster = Elasticsearch::Model.client.cluster
      assert_equal 'yellow', cluster.health["status"]
  end
end
