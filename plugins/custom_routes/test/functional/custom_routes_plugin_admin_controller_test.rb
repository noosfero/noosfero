require 'test_helper'

class CustomRoutesPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @admin = create_user.person
    login_as(@admin.identifier)
    @environment.add_admin(@admin)

    @route = CustomRoutesPlugin::Route.create(
      source_url: '/source',
      target_url: "/profile/#{@admin.identifier}",
      environment_id: Environment.default.id
    )
  end

  should 'list all custom routes' do
    get :index
    assert_tag 'td', content: '/source'
    assert_tag 'td', content: "/profile/#{@admin.identifier}"
  end

  should 'create a new route with valid info' do
    assert_difference '@environment.custom_routes.where(enabled: false).count' do
      post :create, route: { 
        source_url: '/another-source',
        target_url: '/',
        environment_id: @environment.id
      }
    end
  end

  should 'not create a new route with invalid info' do
    assert_no_difference '@environment.custom_routes.count' do
      post :create, route: { 
        source_url: '/another source',
        target_url: 'http://invalid',
        environment_id: @environment.id
      }
    end
  end

  should 'update route with info' do
    post :update, route_id: @route.id, route: {
      source_url: '/another-source'
    }

    @route.reload
    assert_equal '/another-source', @route.source_url
    assert_equal false, @route.enabled
  end

  should 'render 404 when updating with an invalid route_id' do
    post :update, route_id: 'invalid', route: {
      source_url: '/another-source'
    }
    assert_equal 404, @response.status
  end

  should 'render 404 when editing with an invalid route_id' do
    get :edit, route_id: 'invalid'
    assert_equal 404, @response.status
  end

  should 'destroy a route' do
    assert_difference '@environment.custom_routes.count', -1 do
      post :destroy, route_id: @route.id
    end
  end

  should 'respond with 400 when it fails to destroy' do
    post :destroy, route_id: 'invalid'
    assert 400, @response.status
  end

end
