require_relative "../test_helper"

class EnableDisableFeaturesTest < ActionDispatch::IntegrationTest

  all_fixtures

  def test_enable_features
    login 'ze', 'test'

    get '/admin/features'
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature1' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature2' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature3' }

    post_via_redirect '/admin/features/update'
    assert_response :success

    assert_response :success
    assert_equal '/admin/features', path

    post_via_redirect '/admin/features/update', :environments => { :enabled_features => [ 'feature1' ], :organization_approval_method => 'region' }
    assert_response :success

    assert_equal '/admin/features', path

  end
end
