require "#{File.dirname(__FILE__)}/../test_helper"

class EnableDisableFeaturesTest < ActionController::IntegrationTest
  fixtures :virtual_communities, :users, :profiles

  def test_enable_features
    uses_host 'anhetegua.net'
    login 'johndoe', 'test'

    get '/admin/features'
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'features[feature1]' }
    assert_tag :tag => 'input', :attributes => { :name => 'features[feature2]' }
    assert_tag :tag => 'input', :attributes => { :name => 'features[feature3]' }

    post '/admin/features/update'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/features', path

    post '/admin/features/update', :features => { 'feature1' => '1' }
    assert_response :redirect

    follow_redirect!
    assert_equal '/admin/features', path

  end
end
