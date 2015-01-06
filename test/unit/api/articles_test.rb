require File.dirname(__FILE__) + '/test_helper'

class ArticlesTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list articles' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["articles"].map { |a| a["id"] }, article.id
  end

  should 'not list forbidden article when listing articles' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json['articles'].map {|a| a['id']}, article.id
  end

  should 'return article by id' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["id"]
  end

  should 'not return article if user has no permission to view it' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'return article by community' do
    community = fast_create(Community)
    article = fast_create(Article, :profile_id => community.id, :name => "Some thing")
    get "/api/v1/communities/#{community.id}/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["id"]
  end

  should 'not return article by community if user has no permission to view it' do
    community = fast_create(Community)
    article = fast_create(Article, :profile_id => community.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/communities/#{community.id}/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not list forbidden article when listing articles by community' do
    community = fast_create(Community)
    article = fast_create(Article, :profile_id => community.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json['articles'].map {|a| a['id']}, article.id
  end

  should 'list article children' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    child1 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
    child2 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [child1.id, child2.id], json["articles"].map { |a| a["id"] }
  end

  should 'not list children of forbidden article' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    child1 = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    child2 = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not return child of forbidden article' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not return private child' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing", :published => false)
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not list private child' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing", :published => false)
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json['articles'].map {|a| a['id']}, child.id
  end

  should 'create article in a community' do
    community = fast_create(Community)
    give_permission(user.person, 'post_content', community)
    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "Title", json["article"]["title"]
  end

  should 'do not create article if user has no permission to post content' do
    community = fast_create(Community)
    give_permission(user.person, 'invite_members', community)
    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'create article with parent' do
    community = fast_create(Community)
    community.add_member(user.person)
    article = fast_create(Article)

    params[:article] = {:name => "Title", :parent_id => article.id}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["parent"]["id"]
  end

end
