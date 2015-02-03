require_relative "../test_helper"

class EnableDisableFeaturesTest < ActionController::IntegrationTest
  all_fixtures

  def test_enable_features
    login 'ze', 'test'

    get '/admin/features'
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature1' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature2' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature3' }

    post '/admin/features/update'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/features', path

    post '/admin/features/update', :environments => { :enabled_features => [ 'feature1' ], :organization_approval_method => 'region' }
    assert_response :redirect

    follow_redirect!
    assert_equal '/admin/features', path

  end
end
