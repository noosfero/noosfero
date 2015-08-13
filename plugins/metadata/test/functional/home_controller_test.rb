require 'test_helper'
require 'home_controller'

class HomeControllerTest < ActionController::TestCase

  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    @environment.enabled_plugins += ['MetadataPlugin']
    @environment.save!
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
