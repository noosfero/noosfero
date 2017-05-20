require 'test_helper'

class RouteTest < ActiveSupport::TestCase

  should 'not create a route without source or target url' do
    route = CustomRoutesPlugin::Route.new(source_url: '/source')
    refute route.valid?

    route = CustomRoutesPlugin::Route.new(target_url: '/')
    refute route.valid?
  end

  should 'not create a route if target or source url are not relative' do
    route = CustomRoutesPlugin::Route.new(source_url: '/source',
                                         target_url: 'https://not.relative')
    refute route.valid?

    route = CustomRoutesPlugin::Route.new(source_url: 'https://not.relative',
                                         target_url: '/')
    refute route.valid?
  end

  should 'not create a route if target or source urls are invalid uris' do
    route = CustomRoutesPlugin::Route.new(source_url: '/source',
                                         target_url: '/not valid')
    refute route.valid?

    route = CustomRoutesPlugin::Route.new(source_url: '/not valid',
                                         target_url: '/target')
    refute route.valid?
  end

  should 'create a route and reload the mappings' do
    CustomRoutesPlugin::CustomRoutes.expects(:reload).returns(true).once
    route = CustomRoutesPlugin::Route.create(
      source_url: '/source',
      target_url: '/',
      environment_id: Environment.default.id
    )
    assert route.valid?
  end

  should 'destroy a route and reload the mappings' do
    CustomRoutesPlugin::CustomRoutes.expects(:reload).returns(true).at_least(2)
    route = CustomRoutesPlugin::Route.create(
      source_url: '/source',
      target_url: '/',
      environment_id: Environment.default.id
    )
    route.destroy
  end

  should 'save route info in a hash' do
    CustomRoutesPlugin::CustomRoutes.expects(:reload).returns(true)
    ActionDispatch::Routing::RouteSet.any_instance.stubs(:recognize_path)
                                     .returns({ route: 'info' })

    route = CustomRoutesPlugin::Route.create(
      source_url: '/source',
      target_url: '/',
      environment_id: Environment.default.id
    )
    assert_equal 'info', route.metadata.symbolize_keys[:route]
  end

end
