require_relative 'test_helper'

class BoxesTest < ActiveSupport::TestCase

  def setup
    login_api
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

end
