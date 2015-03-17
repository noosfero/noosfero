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

  #############################
  #     Community Articles    #
  #############################

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

  should 'create article with content type passed as parameter' do
    community = fast_create(Community)
    community.add_member(user.person)

    Article.delete_all
    params[:article] = {:name => "Title"}
    params[:content_type] = 'TextArticle'
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_kind_of TextArticle, Article.last
  end
  
  should 'create article of TinyMceArticle type if no content type is passed as parameter' do
    community = fast_create(Community)
    community.add_member(user.person)

    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_kind_of TinyMceArticle, Article.last
  end

  should 'not create article with invalid article content type' do
    community = fast_create(Community)
    community.add_member(user.person)

    params[:article] = {:name => "Title"}
    params[:content_type] = 'Person'
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal 403, last_response.status
  end

  should 'create article defining the correct profile' do
    community = fast_create(Community)
    community.add_member(user.person)

    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal community, Article.last.profile
  end

  should 'create article defining the created_by' do
    community = fast_create(Community)
    community.add_member(user.person)

    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal user.person, Article.last.created_by
  end

  should 'create article defining the last_changed_by' do
    community = fast_create(Community)
    community.add_member(user.person)

    params[:article] = {:name => "Title"}
    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal user.person, Article.last.last_changed_by
  end

  #############################
  #       Person Articles     #
  #############################

  should 'return article by person' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    get "/api/v1/people/#{person.id}/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["id"]
  end

  should 'not return article by person if user has no permission to view it' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/people/#{person.id}/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not list forbidden article when listing articles by person' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?
    get "/api/v1/people/#{person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json['articles'].map {|a| a['id']}, article.id
  end

  should 'create article in a person' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "Title", json["article"]["title"]
  end

  should 'person do not create article if user has no permission to post content' do
    person = fast_create(Person)
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{person.id}/articles?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'person create article with parent' do
    article = fast_create(Article)

    params[:article] = {:name => "Title", :parent_id => article.id}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["parent"]["id"]
  end

  should 'person create article with content type passed as parameter' do
    Article.delete_all
    params[:article] = {:name => "Title"}
    params[:content_type] = 'TextArticle'
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_kind_of TextArticle, Article.last
  end
  
  should 'person create article of TinyMceArticle type if no content type is passed as parameter' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_kind_of TinyMceArticle, Article.last
  end

  should 'person not create article with invalid article content type' do
    params[:article] = {:name => "Title"}
    params[:content_type] = 'Person'
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal 403, last_response.status
  end

  should 'person create article defining the correct profile' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal user.person, Article.last.profile
  end

  should 'person create article defining the created_by' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal user.person, Article.last.created_by
  end

  should 'person create article defining the last_changed_by' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal user.person, Article.last.last_changed_by
  end


end
