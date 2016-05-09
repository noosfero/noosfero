require_relative '../test_helper'

class WebfingerTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'return correct user via webfinger url' do
    get '.well-known/webfinger?resource=acct%3Aze%40example.com'
    webfinger =  JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal webfinger['subject'], 'acct:ze@example.com'
  end

  should 'return correct article via webfinger url' do
    get '.well-known/webfinger?resource=http://example.com/article/id/1'
    webfinger =  JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal webfinger['subject'], 'http://example.com/article/id/1'
  end
end
