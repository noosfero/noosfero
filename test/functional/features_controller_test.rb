require File.dirname(__FILE__) + '/../test_helper'
require 'features_controller'

# Re-raise errors caught by the controller.
class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < Test::Unit::TestCase

  fixtures :virtual_communities, :domains

  def setup
    @controller = FeaturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_listing_features
    uses_host 'anhetegua.net'
    get :index
    assert_template 'index'
    VirtualCommunity.available_features.each do |feature, text|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "features[#{feature}]" })
    end
  end

  def test_update
    uses_host 'anhetegua.net'
    post :update, :features => { 'feature1' => '1', 'feature2' => '1' }
    assert_redirected_to :action => 'index'
    assert_kind_of String, flash[:notice]
    v = VirtualCommunity.find(virtual_communities(:anhetegua_net).id)
    assert v.enabled?('feature2')
    assert v.enabled?('feature2') 
    assert !v.enabled?('feature3')
  end

  def test_update_disable_all
    uses_host 'anhetegua.net'
    post :update # no features
    assert_redirected_to :action => 'index'
    assert_kind_of String, flash[:notice]
    v = VirtualCommunity.find(virtual_communities(:anhetegua_net).id)
    assert !v.enabled?('feature1')
    assert !v.enabled?('feature2')
    assert !v.enabled?('feature3')
  end

  def test_update_no_post
    uses_host 'anhetegua.net'
    get :update
    assert_redirected_to :action => 'index'
  end

end
