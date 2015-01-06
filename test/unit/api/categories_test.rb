require File.dirname(__FILE__) + '/test_helper'

class CategoriesTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list categories' do
    category = fast_create(Category)
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["categories"].map { |c| c["name"] }, category.name
  end

  should 'get category by id' do
    category = fast_create(Category)
    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal category.name, json["category"]["name"]
  end

end
