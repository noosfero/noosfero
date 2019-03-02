require_relative "../test_helper"

class EnableDisableFeaturesTest < ActionDispatch::IntegrationTest

  all_fixtures

  def test_enable_features
    #Environment.default.add_admin Profile['ze']
    #login_as_rails5 'ze'
    login_as_rails5(create_admin_user(Environment.default))

    get features_path
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature1' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature2' }
    assert_tag :tag => 'input', :attributes => { :name => 'environment[enabled_features][]', :value => 'feature3' }

    post update_features_path
    follow_redirect!

    assert_response :success

    assert_response :success
    assert_equal '/admin/features', path

    post update_features_path, params: {environments: { enabled_features: [ 'feature1' ],
                                                            organization_approval_method: 'region'
                                                          }
                                           }
    follow_redirect!

    assert_response :success

    assert_equal '/admin/features', path

  end
end
