require File.dirname(__FILE__) + '/../test_helper'
require 'features_controller'

# Re-raise errors caught by the controller.
class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < Test::Unit::TestCase

  all_fixtures 
  def setup
    @controller = FeaturesController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
    login_as(create_admin_user(Environment.find(2)))
  end
  
  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_listing_features
    uses_host 'anhetegua.net'
    get :index
    assert_template 'index'
    Environment.available_features.each do |feature, text|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "environment[enabled_features][]", :value => feature})
    end
  end

  def test_updates_enabled_features
    uses_host 'anhetegua.net'
    post :update, :environment => { :enabled_features => [ 'feature1', 'feature2' ] }
    assert_redirected_to :action => 'index'
    assert_kind_of String, flash[:notice]
    v = Environment.find(environments(:anhetegua_net).id)
    assert v.enabled?('feature2')
    assert v.enabled?('feature2') 
    assert !v.enabled?('feature3')
  end

  def test_update_disable_all
    uses_host 'anhetegua.net'
    post :update # no features
    assert_redirected_to :action => 'index'
    assert_kind_of String, flash[:notice]
    v = Environment.find(environments(:anhetegua_net).id)
    assert !v.enabled?('feature1')
    assert !v.enabled?('feature2')
    assert !v.enabled?('feature3')
  end

  def test_update_no_post
    uses_host 'anhetegua.net'
    get :update
    assert_redirected_to :action => 'index'
  end

  def test_updates_organization_approval_method
    uses_host 'anhetegua.net'
    post :update, :environment => { :organization_approval_method => 'region' }
    assert_redirected_to :action => 'index'
    assert_kind_of String, flash[:notice]
    v = Environment.find(environments(:anhetegua_net).id)
    assert_equal :region, v.organization_approval_method
  end

  def test_should_mark_current_organization_approval_method_in_view
    uses_host 'anhetegua.net'
    Environment.find(environments(:anhetegua_net).id).update_attributes(:organization_approval_method => :region)

    post :index

    assert_tag :tag => 'select', :attributes => { :name => 'environment[organization_approval_method]' }, :descendant => { :tag => 'option', :attributes => { :value => 'region', :selected => true } }


  end

end
