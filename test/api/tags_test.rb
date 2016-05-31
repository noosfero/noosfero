require_relative 'test_helper'

class TagsTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
  end

  should 'get article tags' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')
    a.tags.create! name: 'foo'

    get "/api/v1/articles/#{a.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['foo'], json
  end

  should 'post article tags' do
    login_api
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 201, last_response.status
    assert_equal ['foo'], a.reload.tag_list
  end

  should 'not post article tags if not authenticated' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 401, last_response.status
    assert_equal [], a.reload.tag_list
  end

  should 'get environment tags' do
    person = fast_create(Person)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get '/api/v1/environment/tags'
    json = JSON.parse(last_response.body)
    assert_equal({ 'first-tag' => 3, 'second-tag' => 2, 'third-tag' => 1 }, json)
  end
end
