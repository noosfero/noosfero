require_relative 'test_helper'

class BoxesTest < ActiveSupport::TestCase

  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    login_api
#    @request = ActionController::TestRequest.new
  end

  kinds= %w[Profile Community Person Enterprise Environment]
  kinds.each do |kind|
    should "get_boxes_from_#{kind.downcase.pluralize}" do
      context_obj = fast_create(kind.constantize)
      box = fast_create(Box, :owner_id => context_obj.id, :owner_type => (kind == 'Environment') ? 'Environment' : 'Profile')
      get "/api/v1/#{kind.downcase.pluralize}/#{context_obj.id}/boxes?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal box.id, json["boxes"].first["id"]
    end
  end

  should 'get boxes from default environment' do
    Environment.delete_all
    environment = fast_create(Environment, :is_default => true)
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    get "/api/v1/environments/default/boxes?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal box.id, json["boxes"].first["id"]
  end

  should 'get boxes from context environment' do
    env = fast_create(Environment, :is_default => true)
    env2 = fast_create(Environment).domains << Domain.new(:name => 'test.host')
    box = fast_create(Box, :owner_id => environment.id, :owner_type => 'Environment')
    get "/api/v1/environments/context/boxes?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equal box.id, json["boxes"].first["id"]
  end

end
