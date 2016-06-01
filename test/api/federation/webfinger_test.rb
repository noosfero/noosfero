require_relative '../test_helper'

class WebfingerTest < ActiveSupport::TestCase
  def setup
    Domain.create(name: 'example.com')
    Environment.default.domains << Domain.last
    User.create(login: 'ze', email: 'ze@localdomain.localdomain', 
                password: 'zeze', password_confirmation: 'zeze')
  end

  should 'return correct user via webfinger url' do
    get '.well-known/webfinger?resource=acct%3Aze%40example.com'
    webfinger =  JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal webfinger['subject'], 'acct:ze@example.com'
  end

  should 'not return json when user not found' do
    invalid_user = 'invalid_user_in_url'
    get ".well-known/webfinger?resource=acct%3A#{invalid_user}%40example.com"
    assert_equal 404, last_response.status
  end

  should 'return correct article via webfinger url' do
    a = fast_create(Article, name: 'my article', profile_id: 1)
    get ".well-known/webfinger?resource=http://example.com/article/id/#{a.id}"
    webfinger =  JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal webfinger['subject'], "http://example.com/article/id/#{a.id}"
  end

  should 'not return json when domain is invalid' do
    invalid_domain = 'doest_not_exist.com'
    get ".well-known/webfinger?resource=http://#{invalid_domain}/article/id/1"
    assert_equal 404, last_response.status
  end

  should 'not return json when entity is not found' do
    get '.well-known/webfinger?resource=http://example.com/article/id/999999'
    assert_equal 404, last_response.status
  end

  should 'not return json when entity does not exist' do
    get '.well-known/webfinger?resource=http://example.com/doest_not_exist/id/1'
    assert_equal 404, last_response.status
  end

  should 'not return json when request is not http' do
    not_http_url = 'kkttc://example.com/article/id/1'
    get ".well-known/webfinger?resource=#{not_http_url}"
    assert_equal 404, last_response.status
  end
end
