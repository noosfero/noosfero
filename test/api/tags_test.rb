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
    assert_equal ['name' => 'foo', 'count' => 1], json
  end

  should 'get article tags limited by default' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    1.upto(22).map do |n| 
      a.tags.create!(:name => "tag #{n}")
    end

    get "/api/v1/articles/#{a.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 20, json.count
  end

  should 'post article tags' do
    login_api
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 201, last_response.status
    assert_equal ['foo'], a.reload.tag_list
  end

  should 'get article tags limited by default after tag post' do
    login_api
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    tags = []
    1.upto(22).map do |n| 
      tags.push("tag #{n}")
    end
    params['tags'] = tags

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 20, json.count
  end


  should 'not post article tags if not authenticated' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 401, last_response.status
    assert_equal [], a.reload.tag_list
  end

  should 'get profile tags' do
    profile = fast_create(Profile)
    profile.tags.create! name: 'foo'

    get "/api/v1/profiles/#{profile.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['name' => 'foo', 'count' => 1], json
  end

  should 'get profile tags limited by default' do
    profile = fast_create(Person)
    1.upto(22).map do |n| 
      profile.tags.create!(:name => "tag #{n}")
    end

    get "/api/v1/profiles/#{profile.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 20, json.count
  end

  should 'post profile tags' do
    login_api
    profile = fast_create(Profile)

    post "/api/v1/profiles/#{profile.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 201, last_response.status
    assert_equal ['foo'], profile.reload.tag_list
  end

  should 'get profile tags limited by default after tag post' do
    login_api
    profile = fast_create(Profile)

    tags = []
    1.upto(22).map do |n| 
      tags.push("tag #{n}")
    end

    params['tags'] = tags
    post "/api/v1/profiles/#{profile.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 20, json.count
  end

  should 'not post profile tags if not authenticated' do
    profile = fast_create(Profile)

    post "/api/v1/profiles/#{profile.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 401, last_response.status
    assert_equal [], profile.reload.tag_list
  end

  should 'get environment tags for path environments with the correct tag counter' do
    person = fast_create(Person)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get '/api/v1/environments/tags'
    json = JSON.parse(last_response.body)
    json.each do |name, count|
      if name == 'first-tag'
        assert_equal(3, count)
      elsif name == 'second-tag'
        assert_equal(2, count)
      elsif name == 'third-tag'
        assert_equal(1, count)
      end
    end
  end

  should 'get environment tags limited by default' do
    person = fast_create(Person)
    1.upto(22).map do |n| 
      person.articles.create!(:name => "article #{n}", :tag_list => "tag #{n}")
    end

    get '/api/v1/environments/tags'
    json = JSON.parse(last_response.body)
    assert_equal 20, json.count
  end

  should 'get environment tags with limit parameter' do
    person = fast_create(Person)
    1.upto(4).map do |n| 
      person.articles.create!(:name => "article #{n}", :tag_list => "tag #{n}")
    end

    limit = 2
    get "/api/v1/environments/tags?limit=#{limit}"
    json = JSON.parse(last_response.body)
    assert_equal limit, json.count
  end

  should 'get environment tags with order parameter' do
    person = fast_create(Person)
    1.upto(4).map do |n| 
      person.articles.create!(:name => "article #{n}", :tag_list => "tag #{n}")
    end
    a = Article.last
    a.tag_list = ["tag 4", "tag 3"]
    a.save

    params['order'] = 'taggings_count DESC'
    get "/api/v1/environments/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json.first['count']
  end

  should 'get environment tags for path environments with status OK' do
    get '/api/v1/environments/tags'
    assert_equal Api::Status::Http::OK, last_response.status
  end

  should 'get environment tags for path environments/:id path' do
    environment = fast_create(Environment)
    person = fast_create(Person, :environment_id => environment.id)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get "/api/v1/environments/#{environment.id}/tags"
    json = JSON.parse(last_response.body)
    json.each do |name, count|
      if name == 'first-tag'
        assert_equal(3, count)
      elsif name == 'second-tag'
        assert_equal(2, count)
      elsif name == 'third-tag'
        assert_equal(1, count)
      end
    end
  end

  should 'get environment tags for path environments/:id with status OK' do
    environment = fast_create(Environment)
    get "/api/v1/environments/#{environment.id}/tags"
    assert_equal Api::Status::Http::OK, last_response.status
  end

end
