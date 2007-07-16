require "#{File.dirname(__FILE__)}/../test_helper"

class RoutingTest < ActionController::IntegrationTest

  def test_features_controller
    assert_routing('admin/features', :controller => 'features', :action => 'index')
  end

end
