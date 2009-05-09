require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < Test::Unit::TestCase

#  all_fixtures:profiles, :environments, :domains
all_fixtures
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  should 'not display form for enterprise activation if disabled in environment' do
    env = Environment.default
    env.disable('enterprise_activation')
    env.save!

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'display form for enterprise activation if enabled on environment' do
    env = Environment.default
    env.enable('enterprise_activation')
    env.save!

    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'not display news from portal if disabled in environment' do
    env = Environment.default
    env.disable('use_portal_community')
    env.save!

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'portal-news' }
  end

  should 'not display news from portal if environment doesnt have portal community' do
    env = Environment.default
    env.enable('use_portal_community')
    env.save!

    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'portal-news' }
  end

  should 'display news from portal if enabled and has portal community' do
    env = Environment.default
    env.enable('use_portal_community')

    c = Community.create!(:name => 'community test')
    env.portal_community = c

    env.save!

    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'portal-news' } #, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end
end
