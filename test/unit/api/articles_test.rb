require_relative 'test_helper'

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
    person = fast_create(Person, :environment_id => environment.id)
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

  should 'list public article children for not logged in access' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    child1 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
    child2 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children"
    json = JSON.parse(last_response.body)
    assert_equivalent [child1.id, child2.id], json["articles"].map { |a| a["id"] }
  end

  should 'not list children of forbidden article' do
    person = fast_create(Person, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    child1 = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    child2 = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not return child of forbidden article' do
    person = fast_create(Person, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not return private child' do
    person = fast_create(Person, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing", :published => false)
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not list private child' do
    person = fast_create(Person, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    child = fast_create(Article, :parent_id => article.id, :profile_id => person.id, :name => "Some thing", :published => false)
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json['articles'].map {|a| a['id']}, child.id
  end

  should 'perform a vote in a article identified by id' do
    article = fast_create(Article, :profile_id => @person.id, :name => "Some thing")
    @params[:value] = 1

    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_not_equal 401, last_response.status
    assert_equal true, json['vote']
  end

  expose_attributes = %w(id body abstract created_at title author profile categories image votes_for votes_against setting position hits start_date end_date tag_list parent children children_count)

  expose_attributes.each do |attr|
    should "expose article #{attr} attribute by default" do
      article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
      get "/api/v1/articles/?#{params.to_query}"
      json = JSON.parse(last_response.body)
     assert json["articles"].last.has_key?(attr)
    end
  end

  should "update body of article created by me" do
    new_value = "Another body"
    params[:article] = {:body => new_value}
    article = fast_create(Article, :profile_id => person.id)
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["article"]["body"]
  end

  should "update title of article created by me" do
    new_value = "Another name"
    params[:article] = {:name => new_value}
    article = fast_create(Article, :profile_id => person.id)
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["article"]["title"]
  end

  should 'not update article of another user' do
    another_person = fast_create(Person, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => another_person.id)
    params[:article] = {:title => 'Some title'}
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not update article without permission in community' do
    community = fast_create(Community, :environment_id => environment.id)
    article = fast_create(Article, :profile_id => community.id)
    params[:article] = {:name => 'New title'}
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end


  should 'update article of community if user has permission' do
    community = fast_create(Community, :environment_id => environment.id)
    give_permission(person, 'post_content', community)
    article = fast_create(Article, :profile_id => community.id)
    new_value = "Another body"
    params[:article] = {:body => new_value}
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["article"]["body"]
  end

  should 'list articles with pagination' do
    Article.destroy_all
    article_one = fast_create(Article, :profile_id => user.person.id, :name => "Another thing", :created_at => 2.days.ago)
    article_two = fast_create(Article, :profile_id => user.person.id, :name => "Some thing", :created_at => 1.day.ago)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/articles/?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/articles/?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    assert_includes json_page_one["articles"].map { |a| a["id"] }, article_two.id
    assert_not_includes json_page_one["articles"].map { |a| a["id"] }, article_one.id

    assert_includes json_page_two["articles"].map { |a| a["id"] }, article_one.id
    assert_not_includes json_page_two["articles"].map { |a| a["id"] }, article_two.id
  end

  should 'list articles with timestamp' do
    article_one = fast_create(Article, :profile_id => user.person.id, :name => "Another thing")
    article_two = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")

    article_one.updated_at = Time.now + 3.hours
    article_one.save!

    params[:timestamp] = Time.now + 1.hours
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json["articles"].map { |a| a["id"] }, article_one.id
    assert_not_includes json["articles"].map { |a| a["id"] }, article_two.id
  end

  #############################
  #     Profile Articles      #
  #############################

  profile_kinds = %w(community person enterprise)
  profile_kinds.each do |kind|
    should "return article by #{kind}" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      article = fast_create(Article, :profile_id => profile.id, :name => "Some thing")
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["article"]["id"]
    end

    should "not return article by #{kind} if user has no permission to view it" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      article = fast_create(Article, :profile_id => profile.id, :name => "Some thing", :published => false)
      assert !article.published?

      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.id}?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    should "not list forbidden article when listing articles by #{kind}" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      article = fast_create(Article, :profile_id => profile.id, :name => "Some thing", :published => false)
      assert !article.published?

      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_not_includes json['articles'].map {|a| a['id']}, article.id
    end

    should "return article by #{kind} and path" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      parent_article = Folder.create!(:profile => profile, :name => "Parent Folder")
      article = Article.create!(:profile => profile, :name => "Some thing", :parent => parent_article)

      params[:path] = parent_article.slug+'/'+article.slug
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["article"]["id"]
    end

    should "not return article by #{kind} and path if user has no permission to view it" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      parent_article = Folder.create!(:profile => profile, :name => "Parent Folder")
      article = Article.create!(:profile => profile, :name => "Some thing", :parent => parent_article, :published => false)

      assert !article.published?

      params[:path] = parent_article.slug+'/'+article.slug
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      assert_equal 403, last_response.status
    end
  end

  #############################
  #  Group Profile Articles   #
  #############################

  group_kinds = %w(community enterprise)
  group_kinds.each do |kind|
    should "#{kind}: create article" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      give_permission(user.person, 'post_content', profile)
      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal "Title", json["article"]["title"]
    end

    should "#{kind}: do not create article if user has no permission to post content" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      give_permission(user.person, 'invite_members', profile)
      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    should "#{kind} create article with parent" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)
      article = fast_create(Article)

      params[:article] = {:name => "Title", :parent_id => article.id}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["article"]["parent"]["id"]
    end

    should "#{kind} create article with content type passed as parameter" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      Article.delete_all
      params[:article] = {:name => "Title"}
      params[:content_type] = 'TextArticle'
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_kind_of TextArticle, Article.last
    end

    should "#{kind}: create article of TinyMceArticle type if no content type is passed as parameter" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_kind_of TinyMceArticle, Article.last
    end

    should "#{kind}: not create article with invalid article content type" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      profile.add_member(user.person)

      params[:article] = {:name => "Title"}
      params[:content_type] = 'Person'
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal 403, last_response.status
    end

    should "#{kind} create article defining the correct profile" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal profile.id, json['article']['profile']['id']
    end

    should "#{kind}: create article defining the created_by" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal user.person, Article.last.created_by
    end

    should "#{kind}: create article defining the last_changed_by" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = {:name => "Title"}
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal user.person, Article.last.last_changed_by
    end
  end

  #############################
  #       Person Articles     #
  #############################

  should 'create article in a person' do
    params[:article] = {:name => "Title"}
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "Title", json["article"]["title"]
  end

  should 'person do not create article if user has no permission to post content' do
    person = fast_create(Person, :environment_id => environment.id)
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

  should 'list article children with partial fields' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    child1 = fast_create(Article, :parent_id => article.id, :profile_id => user.person.id, :name => "Some thing")
    params[:fields] = [:title]
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['title'], json['articles'].first.keys
  end

  should 'suggest article children' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    params[:target_id] = user.person.id
    params[:article] = {:name => "Article name", :body => "Article body"}
    assert_difference "SuggestArticle.count" do
      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert_equal 'SuggestArticle', json['task']['type']
  end

  should 'suggest event children' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    params[:target_id] = user.person.id
    params[:article] = {:name => "Article name", :body => "Article body", :type => "Event"}
    assert_difference "SuggestArticle.count" do
      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert_equal 'SuggestArticle', json['task']['type']
  end

  should 'update hit attribute of article children' do
    a1 = fast_create(Article, :profile_id => user.person.id)
    a2 = fast_create(Article, :parent_id => a1.id, :profile_id => user.person.id)
    a3 = fast_create(Article, :parent_id => a1.id, :profile_id => user.person.id)
    get "/api/v1/articles/#{a1.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [1, 1], json['articles'].map { |a| a['hits']}
    assert_equal [0, 1, 1], [a1.reload.hits, a2.reload.hits, a3.reload.hits]
  end

  should 'update hit attribute of article specific children' do
    a1 = fast_create(Article, :profile_id => user.person.id)
    a2 = fast_create(Article, :parent_id => a1.id, :profile_id => user.person.id)
    get "/api/v1/articles/#{a1.id}/children/#{a2.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['article']['hits']
  end

  should 'list all events of a community in a given category' do
    co = Community.create(identifier: 'my-community', name: 'name-my-community')
    c1 = Category.create(environment: Environment.default, name: 'my-category')
    c2 = Category.create(environment: Environment.default, name: 'dont-show-me-this-category')
    e1 = fast_create(Event, :profile_id => co.id)
    e2 = fast_create(Event, :profile_id => co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params['content_type']='Event'
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['articles'].count, 2
  end

  should 'list a event of a community in a given category' do
    co = Community.create(identifier: 'my-community', name: 'name-my-community')
    c1 = Category.create(environment: Environment.default, name: 'my-category')
    c2 = Category.create(environment: Environment.default, name: 'dont-show-me-this-category')
    e1 = fast_create(Event, :profile_id => co.id)
    e2 = fast_create(Event, :profile_id => co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params['category_ids[]']=c1.id
    params['content_type']='Event'
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    #should show only one article, since the other not in the same category
    assert_equal 1, json['articles'].count
    assert_equal e1.id, json['articles'][0]['id']
  end

  should 'not list uncategorized event of a community if a category is given' do
    co = Community.create(identifier: 'my-community', name: 'name-my-community')
    c1 = Category.create(environment: Environment.default, name: 'my-category')
    c2 = Category.create(environment: Environment.default, name: 'dont-show-me-this-category')
    e1 = fast_create(Event, :profile_id => co.id)
    e2 = fast_create(Event, :profile_id => co.id)
    e3 = fast_create(Event, :profile_id => co.id)
    e1.categories << c1
    e2.categories << c2
    params['category_ids[]']=c1.id
    params['content_type']='Event'
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['articles'].count
    assert_equal e1.id, json['articles'][0]['id']
  end

  should 'list events of a community in a given 2 categories' do
    co = Community.create(identifier: 'my-community', name: 'name-my-community')
    c1 = Category.create(environment: Environment.default, name: 'my-category')
    c2 = Category.create(environment: Environment.default, name: 'dont-show-me-this-category')
    e1 = fast_create(Event, :profile_id => co.id)
    e2 = fast_create(Event, :profile_id => co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params['content_type']='Event'
    params['categories_ids'] = [c1.id, c2.id]
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['articles'].count, 2
  end

  should 'Show 2 events since it uses an IN operator for category instead of an OR' do
    co = Community.create(identifier: 'my-community', name: 'name-my-community')
    c1 = Category.create(environment: Environment.default, name: 'my-category')
    c2 = Category.create(environment: Environment.default, name: 'dont-show-me-this-category')
    c3 = Category.create(environment: Environment.default, name: 'extra-category')
    e1 = fast_create(Event, :profile_id => co.id)
    e2 = fast_create(Event, :profile_id => co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params['content_type']='Event'
    params['categories_ids'] = [c1.id, c2.id, c3.id]
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['articles'].count, 2
  end

end
