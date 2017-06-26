require 'test_helper'

class CustomRoutesTest < ActionDispatch::IntegrationTest

  def setup
    create_user('ze')
    @route = CustomRoutesPlugin::Route.create(
      source_url: '/source',
      target_url: '/profile/ze',
      environment_id: Environment.default.id
    )
  end

  should 'create a new route mapping' do
    get @route.source_url
    assert_template "profile/index"
  end

  should 'not map disabled route' do
    @route.update(enabled: false)
    get @route.source_url
    assert_template "shared/not_found"
  end

  should 'remove route mapping if route is destroyed' do
    @route.destroy
    get @route.source_url
    assert_template "not_found"
  end

  should 'not break when reloading routes with invalid records' do
    fast_create(CustomRoutesPlugin::Route, source_url: '/source',
                target_url: '/target', environment_id: Environment.default.id,
                metadata: {})

    assert_nothing_raised do
      CustomRoutesPlugin::CustomRoutes.reload
    end
  end

end
