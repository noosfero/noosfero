require File.dirname(__FILE__) + '/test_helper'

class EnterprisesTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list enterprises' do
    enterprise1 = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map {|c| c['id']}, enterprise1.id
    assert_includes json.map {|c| c['id']}, enterprise2.id
  end

  should 'return one enterprise by id' do
    enterprise = fast_create(Enterprise)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal enterprise.id, json['id']
  end

end
