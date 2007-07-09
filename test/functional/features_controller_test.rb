require File.dirname(__FILE__) + '/../test_helper'
require 'features_controller'

# Re-raise errors caught by the controller.
class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < Test::Unit::TestCase
  def setup
    @controller = FeaturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_listing_features
    get :index
    assert_template 'index'
    VirtualCommunity::EXISTING_FEATURES.each do |feature, text|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "feature[#{feature}]" })
    end
  end

  def test_update_features
    fail 'Not implemented yet'
  end

end
