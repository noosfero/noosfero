require 'test_helper'
require 'home_controller'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < ActionController::TestCase

  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Noosfero::Plugin.stubs(:all).returns([MetadataPlugin.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([MetadataPlugin.new])
  end

  should 'display meta tags for social media' do
    get :index
    assert_tag :tag => 'meta', :attributes => { :name => 'twitter:card', :content => 'summary' }
    assert_tag :tag => 'meta', :attributes => { :name => 'twitter:title', :content => assigns(:environment).name }
    assert_tag :tag => 'meta', :attributes => { :name => 'twitter:description', :content => assigns(:environment).name }
    assert_no_tag :tag => 'meta', :attributes => { :name => 'twitter:image' }
    assert_tag :tag => 'meta', :attributes => { :property => 'og:type', :content => 'website' }
    assert_tag :tag => 'meta', :attributes => { :property => 'og:url', :content => assigns(:environment).top_url }
    assert_tag :tag => 'meta', :attributes => { :property => 'og:title', :content => assigns(:environment).name }
    assert_tag :tag => 'meta', :attributes => { :property => 'og:site_name', :content => assigns(:environment).name }
    assert_tag :tag => 'meta', :attributes => { :property => 'og:description', :content => assigns(:environment).name }
    assert_no_tag :tag => 'meta', :attributes => { :property => 'article:published_time' }
    assert_no_tag :tag => 'meta', :attributes => { :property => 'og:image' }
  end

end
