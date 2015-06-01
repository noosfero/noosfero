require File.dirname(__FILE__) + '/test_helper'

class TasksTest < ActiveSupport::TestCase

  def setup
    login_api
    @person = user.person
    @community = fast_create(Community)
    @environment = Environment.default
  end

  attr_accessor :person, :community, :environment

  should 'list tasks' do
    task = fast_create(Task, :requestor_id => environment.id, :target_id => community.id)
    get "/api/v1/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["tasks"].map { |a| a["id"] }, task.id
  end

  should 'return environment task by id' do
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return environmet task if user has no permission to view it' do
    person = fast_create(Person)
    task = create(Task, :requestor => person, :target => environment)

    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  #############################
  #     Community Tasks    #
  #############################

  should 'return task by community' do
    community = fast_create(Community)
    task = create(Task, :requestor => person, :target => community)
    get "/api/v1/communities/#{community.id}/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return task by community if user has no permission to view it' do
    community = fast_create(Community)
    task = create(Task, :requestor => person, :target => community)
    assert !person.is_member_of?(community)

    get "/api/v1/communities/#{community.id}/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

#  should 'not list forbidden article when listing articles by community' do
#    community = fast_create(Community)
#    article = fast_create(Article, :profile_id => community.id, :name => "Some thing", :published => false)
#    assert !article.published?
#
#    get "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_not_includes json['articles'].map {|a| a['id']}, article.id
#  end

  should 'create task in a community' do
    community = fast_create(Community)
    give_permission(person, 'post_content', community)
    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["task"]["id"]
  end

  should 'do not create article if user has no permission to post content' do
assert false
#    community = fast_create(Community)
#    give_permission(user.person, 'invite_members', community)
#    params[:article] = {:name => "Title"}
#    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
#    assert_equal 403, last_response.status
  end

#  should 'create article with parent' do
#    community = fast_create(Community)
#    community.add_member(user.person)
#    article = fast_create(Article)
#
#    params[:article] = {:name => "Title", :parent_id => article.id}
#    post "/api/v1/communities/#{community.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal article.id, json["article"]["parent"]["id"]
#  end

  should 'create task defining the requestor as current profile logged in' do
    community = fast_create(Community)
    community.add_member(person)

    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal person, Task.last.requestor
  end

  should 'create task defining the target as the community' do
    community = fast_create(Community)
    community.add_member(person)

    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    
    assert_equal community, Task.last.target
  end

#  #############################
#  #       Person Articles     #
#  #############################
#
#  should 'return article by person' do
#    person = fast_create(Person)
#    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
#    get "/api/v1/people/#{person.id}/articles/#{article.id}?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal article.id, json["article"]["id"]
#  end
#
#  should 'not return article by person if user has no permission to view it' do
#    person = fast_create(Person)
#    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
#    assert !article.published?
#
#    get "/api/v1/people/#{person.id}/articles/#{article.id}?#{params.to_query}"
#    assert_equal 403, last_response.status
#  end
#
#  should 'not list forbidden article when listing articles by person' do
#    person = fast_create(Person)
#    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
#    assert !article.published?
#    get "/api/v1/people/#{person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_not_includes json['articles'].map {|a| a['id']}, article.id
#  end
#
#  should 'create article in a person' do
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal "Title", json["article"]["title"]
#  end
#
#  should 'person do not create article if user has no permission to post content' do
#    person = fast_create(Person)
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{person.id}/articles?#{params.to_query}"
#    assert_equal 403, last_response.status
#  end
#
#  should 'person create article with parent' do
#    article = fast_create(Article)
#
#    params[:article] = {:name => "Title", :parent_id => article.id}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal article.id, json["article"]["parent"]["id"]
#  end
#
#  should 'person create article with content type passed as parameter' do
#    Article.delete_all
#    params[:article] = {:name => "Title"}
#    params[:content_type] = 'TextArticle'
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_kind_of TextArticle, Article.last
#  end
#  
#  should 'person create article of TinyMceArticle type if no content type is passed as parameter' do
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_kind_of TinyMceArticle, Article.last
#  end
#
#  should 'person not create article with invalid article content type' do
#    params[:article] = {:name => "Title"}
#    params[:content_type] = 'Person'
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal 403, last_response.status
#  end
#
#  should 'person create article defining the correct profile' do
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal user.person, Article.last.profile
#  end
#
#  should 'person create article defining the created_by' do
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal user.person, Article.last.created_by
#  end
#
#  should 'person create article defining the last_changed_by' do
#    params[:article] = {:name => "Title"}
#    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal user.person, Article.last.last_changed_by
#  end
#
#  #############################
#  #     Enterprise Articles    #
#  #############################
#
#  should 'return article by enterprise' do
#    enterprise = fast_create(Enterprise)
#    article = fast_create(Article, :profile_id => enterprise.id, :name => "Some thing")
#    get "/api/v1/enterprises/#{enterprise.id}/articles/#{article.id}?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal article.id, json["article"]["id"]
#  end
#
#  should 'not return article by enterprise if user has no permission to view it' do
#    enterprise = fast_create(Enterprise)
#    article = fast_create(Article, :profile_id => enterprise.id, :name => "Some thing", :published => false)
#    assert !article.published?
#
#    get "/api/v1/enterprises/#{enterprise.id}/articles/#{article.id}?#{params.to_query}"
#    assert_equal 403, last_response.status
#  end
#
#  should 'not list forbidden article when listing articles by enterprise' do
#    enterprise = fast_create(Enterprise)
#    article = fast_create(Article, :profile_id => enterprise.id, :name => "Some thing", :published => false)
#    assert !article.published?
#
#    get "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_not_includes json['articles'].map {|a| a['id']}, article.id
#  end
#
#  should 'create article in a enterprise' do
#    enterprise = fast_create(Enterprise)
#    give_permission(user.person, 'post_content', enterprise)
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal "Title", json["article"]["title"]
#  end
#
#  should 'enterprise: do not create article if user has no permission to post content' do
#    enterprise = fast_create(Enterprise)
#    give_permission(user.person, 'invite_members', enterprise)
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    assert_equal 403, last_response.status
#  end
#
#  should 'enterprise: create article with parent' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#    article = fast_create(Article)
#
#    params[:article] = {:name => "Title", :parent_id => article.id}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal article.id, json["article"]["parent"]["id"]
#  end
#
#  should 'enterprise: create article with content type passed as parameter' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    Article.delete_all
#    params[:article] = {:name => "Title"}
#    params[:content_type] = 'TextArticle'
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_kind_of TextArticle, Article.last
#  end
#  
#  should 'enterprise: create article of TinyMceArticle type if no content type is passed as parameter' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_kind_of TinyMceArticle, Article.last
#  end
#
#  should 'enterprise: not create article with invalid article content type' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    params[:article] = {:name => "Title"}
#    params[:content_type] = 'Person'
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal 403, last_response.status
#  end
#
#  should 'enterprise: create article defining the correct profile' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal enterprise, Article.last.profile
#  end
#
#  should 'enterprise: create article defining the created_by' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal user.person, Article.last.created_by
#  end
#
#  should 'enterprise: create article defining the last_changed_by' do
#    enterprise = fast_create(Enterprise)
#    enterprise.add_member(user.person)
#
#    params[:article] = {:name => "Title"}
#    post "/api/v1/enterprises/#{enterprise.id}/articles?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    
#    assert_equal user.person, Article.last.last_changed_by
#  end
#
#  should 'list article children with partial fields' do
#    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
#    child1 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
#    params[:fields] = [:title]
#    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal ['title'], json['articles'].first.keys
#  end
#
#  should 'suggest article children' do
#    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
#    params[:target_id] = user.person.id
#    params[:article] = {:name => "Article name", :body => "Article body"}
#    assert_difference "SuggestArticle.count" do
#      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
#    end
#    json = JSON.parse(last_response.body)
#    assert_equal 'SuggestArticle', json['type']
#  end
#
#  should 'suggest event children' do
#    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
#    params[:target_id] = user.person.id
#    params[:article] = {:name => "Article name", :body => "Article body", :type => "Event"}
#    assert_difference "SuggestArticle.count" do
#      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
#    end
#    json = JSON.parse(last_response.body)
#    assert_equal 'SuggestArticle', json['type']
#  end
#
#  should 'update hit attribute of article children' do
#    a1 = fast_create(Article, :profile_id => user.person.id)
#    a2 = fast_create(Article, :parent_id => a1.id, :profile_id => user.person.id)
#    a3 = fast_create(Article, :parent_id => a1.id, :profile_id => user.person.id)
#    get "/api/v1/articles/#{a1.id}/children?#{params.to_query}"
#    json = JSON.parse(last_response.body)
#    assert_equal [1, 1], json['articles'].map { |a| a['hits']}
#    assert_equal [0, 1, 1], [a1.reload.hits, a2.reload.hits, a3.reload.hits]
#  end
#
end
