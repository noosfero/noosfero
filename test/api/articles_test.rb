require_relative "test_helper"

class ArticlesTest < ActiveSupport::TestCase
  def setup
    create_and_activate_user
    login_api
  end

  expose_attributes = %w(id body abstract created_at title author profile categories image votes_for votes_against setting position hits start_date end_date tag_list parent_id children children_count url access)

  expose_attributes.each do |attr|
    should "expose article #{attr} attribute by default" do
      article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
      get "/api/v1/articles/?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert json.last.has_key?(attr)
    end
  end

  should "remove article return 200 http status" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    delete "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
  end

  should "remove article return success" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    delete "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal true, json["success"]
  end

  should "remove article return no content noosfero status code" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    delete "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal Api::Status::Http::NO_CONTENT, json["code"]
  end

  should "remove article erase the data from database" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    delete "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert !Article.exists?(article.id)
  end

  should "create uploaded file type article" do
    params["article"] = { name: "UploadedFileArticle", type: "UploadedFile", uploaded_data: { path: "/files/rails.png" } }
    ActionDispatch::Http::UploadedFile.expects(:new).with("path" => "/files/rails.png").returns(fixture_file_upload("/files/rails.png", "image/png"))
    post "/api/v1/profiles/#{person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["public_filename"].present?
    assert Article.find(json["id"]).present?
  end

  should "not remove article without permission" do
    otherPerson = fast_create(Person, name: "Other Person")
    article = fast_create(Article, profile_id: otherPerson.id, name: "Some thing")
    delete "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 403, last_response.status
    assert Article.exists?(article.id)
  end

  should "list articles" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json.map { |a| a["id"] }, article.id
  end

  should "list all text articles" do
    profile = Community.create(identifier: "my-community", name: "name-my-community")
    a1 = fast_create(TextArticle, profile_id: profile.id)
    a2 = fast_create(TextArticle, profile_id: profile.id)
    a3 = fast_create(TextArticle, profile_id: profile.id)
    params["content_type"] = "TextArticle"
    get "api/v1/communities/#{profile.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 3, json.count
  end

  should "get profile homepage" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    person.home_page = article
    person.save!

    get "/api/v1/profiles/#{person.id}/home_page?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["id"]
  end

  should "not list forbidden article when listing articles" do
    person = fast_create(Person)
    article = fast_create(Article, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    assert !article.published?

    get "/api/v1/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.map { |a| a["id"] }, article.id
  end

  should "return article by id" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["id"]
  end

  should "not return article if user has no permission to view it" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    assert !article.published?

    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "follow a article identified by id" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing")
    post "/api/v1/articles/#{article.id}/follow?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_not_equal 401, last_response.status
    assert_equal true, json["success"]
  end

  should "return the followers count of an article" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing")
    article.person_followers << @person

    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_equal 1, json["followers_count"]
  end

  should "list articles followed by me" do
    article1 = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    fast_create(Article, profile_id: user.person.id, name: "Some other thing")
    article1.person_followers << @person
    get "/api/v1/articles/followed_by_me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [article1.id], json.map { |a| a["id"] }
  end

  should "list article children" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    child1 = fast_create(Article, parent_id: article.id, profile_id: user.person.id, name: "Some thing")
    child2 = fast_create(Article, parent_id: article.id, profile_id: user.person.id, name: "Some thing")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [child1.id, child2.id], json.map { |a| a["id"] }
  end

  should "list all text articles of children" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    child1 = fast_create(TextArticle, parent_id: article.id, profile_id: user.person.id, name: "Some thing 1")
    child2 = fast_create(TextArticle, parent_id: article.id, profile_id: user.person.id, name: "Some thing 2")
    child3 = fast_create(TextArticle, parent_id: article.id, profile_id: user.person.id, name: "Some thing 3")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [child1.id, child2.id, child3.id], json.map { |a| a["id"] }
  end

  should "list public article children for not logged in access" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    child1 = fast_create(Article, parent_id: article.id, profile_id: user.person.id, name: "Some thing")
    child2 = fast_create(Article, parent_id: article.id, profile_id: user.person.id, name: "Some thing")
    get "/api/v1/articles/#{article.id}/children"
    json = JSON.parse(last_response.body)
    assert_equivalent [child1.id, child2.id], json.map { |a| a["id"] }
  end

  should "not list children of forbidden article" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    child1 = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing")
    child2 = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing")
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "not return child of forbidden article" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    child = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing")
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "not return private child" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing")
    child = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    get "/api/v1/articles/#{article.id}/children/#{child.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "not list private child" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing")
    child = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.map { |a| a["id"] }, child.id
  end

  should "perform a vote in a article identified by id" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing")
    @params[:value] = 1

    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_not_equal 401, last_response.status
    assert_equal true, json["success"]
  end

  should "not perform a vote twice in same article" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing")
    @params[:value] = 1
    ## Perform a vote twice in API should compute only one vote
    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"

    total = article.votes_total

    assert_equal 1, total
  end

  should "not perform a vote in favor and against a proposal" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing")
    @params[:value] = 1
    ## Perform a vote in favor a proposal
    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    ## Perform a vote against a proposal
    @params[:value] = -1
    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    json = JSON.parse(last_response.body)
    ## The api should not allow to save this vote
    assert_equal Api::Status::Http::UNPROCESSABLE_ENTITY, last_response.status
  end

  should "not perform a vote in a archived article" do
    article = fast_create(Article, profile_id: @person.id, name: "Some thing", archived: true)
    @params[:value] = 1
    post "/api/v1/articles/#{article.id}/vote?#{params.to_query}"
    assert_equal Api::Status::Http::UNPROCESSABLE_ENTITY, last_response.status
  end

  should "not update hit attribute of a specific child if a article is archived" do
    folder = fast_create(Folder, profile_id: user.person.id, archived: true)
    article = fast_create(Article, parent_id: folder.id, profile_id: user.person.id)
    get "/api/v1/articles/#{folder.id}/children/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 0, json["hits"]
  end

  should "find archived articles" do
    article1 = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    article2 = fast_create(Article, profile_id: user.person.id, name: "Some thing", archived: true)
    params[:archived] = true
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.map { |a| a["id"] }, article1.id
    assert_includes json.map { |a| a["id"] }, article2.id
  end

  should "update body of article created by me" do
    new_value = "Another body"
    params[:article] = { body: new_value }
    article = fast_create(Article, profile_id: person.id)
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["body"]
  end

  should "update title of article created by me" do
    new_value = "Another name"
    params[:article] = { name: new_value }
    article = fast_create(Article, profile_id: person.id)
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["title"]
  end

  should "not update article of another user" do
    another_person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: another_person.id)
    params[:article] = { title: "Some title" }
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "not update article without permission in community" do
    community = fast_create(Community, environment_id: environment.id)
    article = fast_create(Article, profile_id: community.id)
    params[:article] = { name: "New title" }
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "update article of community if user has permission" do
    community = fast_create(Community, environment_id: environment.id)
    give_permission(person, "post_content", community)
    article = fast_create(Article, profile_id: community.id)
    new_value = "Another body"
    params[:article] = { body: new_value }
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal new_value, json["body"]
  end

  should "list articles with pagination" do
    Article.delete_all
    article_one = fast_create(Article, profile_id: user.person.id, name: "Another thing", created_at: 2.days.ago)
    article_two = fast_create(Article, profile_id: user.person.id, name: "Some thing", created_at: 1.day.ago)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/articles/?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/articles/?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    assert_includes json_page_one.map { |a| a["id"] }, article_two.id
    assert_not_includes json_page_one.map { |a| a["id"] }, article_one.id

    assert_includes json_page_two.map { |a| a["id"] }, article_one.id
    assert_not_includes json_page_two.map { |a| a["id"] }, article_two.id
  end

  should "list articles with timestamp" do
    article_one = fast_create(Article, profile_id: user.person.id, name: "Another thing")
    article_two = fast_create(Article, profile_id: user.person.id, name: "Some thing")

    article_one.updated_at = Time.now.in_time_zone + 3.hours
    article_one.save!

    params[:timestamp] = Time.now.in_time_zone + 1.hours
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map { |a| a["id"] }, article_one.id
    assert_not_includes json.map { |a| a["id"] }, article_two.id
  end

  #############################
  #     Profile Articles      #
  #############################

  profile_kinds = %w(community person enterprise)
  profile_kinds.each do |kind|
    should "return article by #{kind}" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      article = fast_create(Article, profile_id: profile.id, name: "Some thing")
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["id"]
    end

    should "not return article by #{kind} if user has no permission to view it" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      article = fast_create(Article, profile_id: profile.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
      assert !article.published?

      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.id}?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    should "not list forbidden article when listing articles by #{kind}" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      article = fast_create(Article, profile_id: profile.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
      assert !article.published?

      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_not_includes json.map { |a| a["id"] }, article.id
    end

    should "return article by #{kind} and path" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      parent_article = Folder.create!(profile: profile, name: "Parent Folder")
      article = Article.create!(profile: profile, name: "Some thing", parent: parent_article)

      params[:key] = "path"
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.path}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["id"]
    end

    should "return an error if there is no article in path of #{kind}" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      parent_article = Folder.create!(profile: profile, name: "Parent Folder")
      article = Article.create!(profile: profile, name: "Some thing", parent: parent_article)

      params[:key] = "path"
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/no-path?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert !json["success"]
      assert_equal Api::Status::Http::NOT_FOUND, json["code"]
    end

    should "not return article by #{kind} and path if user has no permission to view it" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      parent_article = Folder.create!(profile: profile, name: "Parent Folder")
      article = Article.create!(profile: profile, name: "Some thing", parent: parent_article, published: false, access: Entitlement::Levels.levels[:self])

      assert !article.published?

      params[:key] = "path"
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{article.path}?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    should "return article by #{kind} and path with key parameter" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      folder = Folder.create!(profile: profile, name: "Folder")
      parent_article = Folder.create!(profile: profile, name: "Parent Folder", parent: folder)
      article = Article.create!(profile: profile, name: "Some thing", parent: parent_article)

      path = folder.slug + "/" + parent_article.slug + "/" + article.slug
      params[:key] = "path"
      get "/api/v1/#{kind.pluralize}/#{profile.id}/articles/#{path}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["id"]
    end
  end

  #############################
  #  Group Profile Articles   #
  #############################

  group_kinds = %w(community enterprise)
  group_kinds.each do |kind|
    should "#{kind}: create article" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      give_permission(user.person, "post_content", profile)
      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal "Title", json["title"]
    end

    should "#{kind}: do not create article if user has no permission to post content" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      give_permission(user.person, "invite_members", profile)
      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    should "#{kind} create article with parent" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)
      article = fast_create(Article)

      params[:article] = { name: "Title", parent_id: article.id }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal article.id, json["parent_id"]
    end

    should "#{kind} create article with content type passed as parameter" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      Article.delete_all
      params[:article] = { name: "Title" }
      params[:content_type] = "TextArticle"
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_kind_of TextArticle, Article.last
    end

    should "#{kind} create article with type passed as parameter" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      Article.delete_all
      params[:article] = { name: "Title", type: "TextArticle" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_kind_of TextArticle, Article.last
    end

    should "#{kind}: create article of TexrArticle type if no content type is passed as parameter" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_kind_of TextArticle, Article.last
    end

    should "#{kind}: not create article with invalid article content type" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      profile.add_member(user.person)

      params[:article] = { name: "Title" }
      params[:content_type] = "Person"
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal 403, last_response.status
    end

    should "#{kind} create article defining the correct profile" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal profile.id, json["profile"]["id"]
    end

    should "#{kind}: create article defining the created_by" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal user.person, Article.last.created_by
    end

    should "#{kind}: create article defining the last_changed_by" do
      profile = fast_create(kind.camelcase.constantize, environment_id: environment.id)
      Person.any_instance.stubs(:can_post_content?).with(profile).returns(true)

      params[:article] = { name: "Title" }
      post "/api/v1/#{kind.pluralize}/#{profile.id}/articles?#{params.to_query}"
      json = JSON.parse(last_response.body)

      assert_equal user.person, Article.last.last_changed_by
    end
  end

  #############################
  #       Person Articles     #
  #############################

  should "create article in a person" do
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "Title", json["title"]
  end

  should "person do not create article if user has no permission to post content" do
    person = fast_create(Person, environment_id: environment.id)
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{person.id}/articles?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "person create article with parent" do
    article = fast_create(Article)

    params[:article] = { name: "Title", parent_id: article.id }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["parent_id"]
  end

  should "person create article with content type passed as parameter" do
    Article.delete_all
    params[:article] = { name: "Title" }
    params[:content_type] = "TextArticle"
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_kind_of TextArticle, Article.last
  end

  should "person create article of TextArticle type if no content type is passed as parameter" do
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_kind_of TextArticle, Article.last
  end

  should "person not create article with invalid article content type" do
    params[:article] = { name: "Title" }
    params[:content_type] = "Person"
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal 403, last_response.status
  end

  should "person create article defining the correct profile" do
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal user.person, Article.last.profile
  end

  should "person create article defining the created_by" do
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal user.person, Article.last.created_by
  end

  should "person create article defining the last_changed_by" do
    params[:article] = { name: "Title" }
    post "/api/v1/people/#{user.person.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal user.person, Article.last.last_changed_by
  end

  should "list article children with partial fields" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    child1 = fast_create(Article, parent_id: article.id, profile_id: user.person.id, name: "Some thing")
    params[:fields] = [:title]
    get "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ["title"], json.first.keys
  end

  should "create article child" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    params[:article] = { name: "Title" }
    post "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["parent_id"]
  end

  should "do not create article child if user has no permission to post content" do
    profile = fast_create(Profile, environment_id: environment.id)
    article = fast_create(Article, profile_id: profile.id, name: "Some thing")
    give_permission(user.person, "invite_members", profile)
    params[:article] = { name: "Title" }
    post "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should "suggest article children" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    params[:target_id] = user.person.id
    params[:article] = { name: "Article name", body: "Article body" }
    assert_difference "SuggestArticle.count" do
      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert_equal "SuggestArticle", json["type"]
  end

  should "suggest event children" do
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    params[:target_id] = user.person.id
    params[:article] = { name: "Article name", body: "Article body", type: "Event" }
    assert_difference "SuggestArticle.count" do
      post "/api/v1/articles/#{article.id}/children/suggest?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert_equal "SuggestArticle", json["type"]
  end

  should "update hit attribute of article children" do
    a1 = fast_create(Article, profile_id: user.person.id)
    a2 = fast_create(Article, parent_id: a1.id, profile_id: user.person.id)
    a3 = fast_create(Article, parent_id: a1.id, profile_id: user.person.id)
    get "/api/v1/articles/#{a1.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [1, 1], json.map { |a| a["hits"] }
    assert_equal [0, 1, 1], [a1.reload.hits, a2.reload.hits, a3.reload.hits]
  end

  should "update hit attribute of article specific children" do
    a1 = fast_create(Article, profile_id: user.person.id)
    a2 = fast_create(Article, parent_id: a1.id, profile_id: user.person.id)
    get "/api/v1/articles/#{a1.id}/children/#{a2.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json["hits"]
  end

  should "list all events of a community in a given category" do
    co = Community.create(identifier: "my-community", name: "name-my-community")
    c1 = Category.create(environment: Environment.default, name: "my-category")
    c2 = Category.create(environment: Environment.default, name: "dont-show-me-this-category")
    e1 = fast_create(Event, profile_id: co.id)
    e2 = fast_create(Event, profile_id: co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params["content_type"] = "Event"
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json.count, 2
  end

  should "list a event of a community in a given category" do
    co = Community.create(identifier: "my-community", name: "name-my-community")
    c1 = Category.create(environment: Environment.default, name: "my-category")
    c2 = Category.create(environment: Environment.default, name: "dont-show-me-this-category")
    e1 = fast_create(Event, profile_id: co.id)
    e2 = fast_create(Event, profile_id: co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params["category_ids[]"] = c1.id
    params["content_type"] = "Event"
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    # should show only one article, since the other not in the same category
    assert_equal 1, json.count
    assert_equal e1.id, json[0]["id"]
  end

  should "not list uncategorized event of a community if a category is given" do
    co = Community.create(identifier: "my-community", name: "name-my-community")
    c1 = Category.create(environment: Environment.default, name: "my-category")
    c2 = Category.create(environment: Environment.default, name: "dont-show-me-this-category")
    e1 = fast_create(Event, profile_id: co.id)
    e2 = fast_create(Event, profile_id: co.id)
    e3 = fast_create(Event, profile_id: co.id)
    e1.categories << c1
    e2.categories << c2
    params["category_ids[]"] = c1.id
    params["content_type"] = "Event"
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.count
    assert_equal e1.id, json[0]["id"]
  end

  should "list events of a community in a given 2 categories" do
    co = Community.create(identifier: "my-community", name: "name-my-community")
    c1 = Category.create(environment: Environment.default, name: "my-category")
    c2 = Category.create(environment: Environment.default, name: "dont-show-me-this-category")
    e1 = fast_create(Event, profile_id: co.id)
    e2 = fast_create(Event, profile_id: co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params["content_type"] = "Event"
    params["categories_ids"] = [c1.id, c2.id]
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json.count, 2
  end

  should "Show 2 events since it uses an IN operator for category instead of an OR" do
    co = Community.create(identifier: "my-community", name: "name-my-community")
    c1 = Category.create(environment: Environment.default, name: "my-category")
    c2 = Category.create(environment: Environment.default, name: "dont-show-me-this-category")
    c3 = Category.create(environment: Environment.default, name: "extra-category")
    e1 = fast_create(Event, profile_id: co.id)
    e2 = fast_create(Event, profile_id: co.id)
    e1.categories << c1
    e2.categories << c2
    e1.save!
    e2.save!
    params["content_type"] = "Event"
    params["categories_ids"] = [c1.id, c2.id, c3.id]
    get "api/v1/communities/#{co.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json.count, 2
  end

  ARTICLE_ATTRIBUTES = %w(followers_count votes_count comments_count)

  ARTICLE_ATTRIBUTES.map do |attribute|
    define_method "test_should_expose_#{attribute}_attribute_in_article_enpoints" do
      article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
      get "/api/v1/articles/#{article.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_not_nil json[attribute]
    end
  end

  should "only show article parent when optional_fields parent is present" do
    person = fast_create(Person)
    article = fast_create(Article, profile_id: person.id, name: "Some thing")

    get "/api/v1/articles/#{article.id}/?#{params.merge(optional_fields: [:parent]).to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json.keys, "parent"

    get "/api/v1/articles/#{article.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.keys, "parent"
  end

  should "only show article comments when optional_fields comments is present" do
    person = fast_create(Person)
    article = fast_create(Article, profile_id: person.id, name: "Some thing")
    article.comments.create!(body: "another comment", author: person)

    get "/api/v1/articles/#{article.id}/?#{params.merge(optional_fields: [:comments]).to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json.keys, "comments"
    assert_equal json["comments"].first["body"], "another comment"

    get "/api/v1/articles/#{article.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.keys, "comments"
  end

  should "not list private child when get the parent article" do
    person = fast_create(Person, environment_id: environment.id)
    article = fast_create(Article, profile_id: person.id, name: "Some thing")
    child = fast_create(Article, parent_id: article.id, profile_id: person.id, name: "Some thing", published: false, access: Entitlement::Levels.levels[:self])
    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json["children"].map { |a| a["id"] }, child.id
  end

  should "list article permissions when get an article" do
    community = fast_create(Community)
    give_permission(person, "post_content", community)
    article = fast_create(Article, profile_id: community.id)
    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["permissions"], "allow_post_content"
  end

  should "return only article fields defined in parameter" do
    Article.delete_all
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    params[:fields] = { only: ["id", "title"] }
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent ["id", "title"], json.first.keys
  end

  should "return all article fields except the ones defined in parameter" do
    Article.delete_all
    article = fast_create(Article, profile_id: user.person.id, name: "Some thing")
    params[:fields] = { except: ["id", "title"] }
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_includes json.first.keys, "id"
    assert_not_includes json.first.keys, "title"
  end

  should "search for articles" do
    article1 = fast_create(TextArticle, profile_id: user.person.id, name: "Some thing")
    article2 = fast_create(TextArticle, profile_id: user.person.id, name: "Other thing")
    params[:search] = "some"
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [article1.id], json.map { |a| a["id"] }
  end

  should "search for articles of different types" do
    article1 = fast_create(Event, profile_id: user.person.id, name: "Some thing")
    article2 = fast_create(TextArticle, profile_id: user.person.id, name: "Some other thing")
    article3 = fast_create(Article, profile_id: user.person.id, name: "Other thing")
    params[:search] = "some"
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [article1.id, article2.id], json.map { |a| a["id"] }
  end

  should "match error messages" do
    profile = fast_create(Community, environment_id: environment.id)
    give_permission(user.person, "post_content", profile)
    params[:article] = { name: "" }
    post "/api/v1/communities/#{profile.id}/articles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ({ "name" => [{ "error" => "blank", "full_message" => "Title can't be blank" }] }), json["errors"]
  end

  should "return error messages when update an article with invalid data" do
    params[:article] = { name: nil }
    article = fast_create(Article, profile_id: person.id)
    post "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ({ "name" => [{ "error" => "blank", "full_message" => "Title can't be blank" }] }), json["errors"]
  end

  should "return event articles from start_date" do
    Article.delete_all
    article = fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1)
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 1)
    params[:from_start_date] = DateTime.now
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return descendent of event articles from start_date" do
    Article.delete_all
    class EventDescendent < Event; end
    article = fast_create(EventDescendent, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1)
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 1)
    params[:from_start_date] = DateTime.now
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return event articles from end_date" do
    Article.delete_all
    fast_create(Event, profile_id: user.person.id, end_date: DateTime.now + 2)
    article = fast_create(Event, profile_id: user.person.id, end_date: DateTime.now)
    fast_create(Event, profile_id: user.person.id)
    params[:until_end_date] = DateTime.now + 1
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return event articles from start_date and end_date" do
    Article.delete_all
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1, end_date: DateTime.now + 2)
    article = fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1, end_date: DateTime.now)
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 1)
    params[:from_start_date] = DateTime.now
    params[:until_end_date] = DateTime.now + 1
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return event articles until start_date and from end_date" do
    Article.delete_all
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1, end_date: DateTime.now + 2)
    article = fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 2, end_date: DateTime.now + 1)
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 2, end_date: DateTime.now - 1)
    params[:until_start_date] = DateTime.now
    params[:from_end_date] = DateTime.now
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return event articles until start_date and from end_date return articles with end_date nil" do
    Article.delete_all
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now + 1, end_date: DateTime.now + 2)
    article = fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 2)
    fast_create(Event, profile_id: user.person.id, name: "Some thing", start_date: DateTime.now - 2, end_date: DateTime.now - 1)
    params[:until_start_date] = DateTime.now
    params[:from_end_date] = DateTime.now
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return articles from start_date" do
    Article.delete_all
    article = fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now + 1)
    fast_create(Event, profile_id: user.person.id, created_at: DateTime.now - 1)
    params[:from_start_date] = DateTime.now
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return articles from end_date" do
    Article.delete_all
    fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now + 2)
    article = fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now)
    fast_create(TextArticle, profile_id: user.person.id)
    params[:until_end_date] = DateTime.now + 1
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end

  should "return articles from start_date and end_date" do
    Article.delete_all
    fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now - 2)
    article = fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now)
    fast_create(TextArticle, profile_id: user.person.id, created_at: DateTime.now + 2)
    params[:from_start_date] = DateTime.now - 1
    params[:until_end_date] = DateTime.now + 1
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.length
    assert_equal json.first["id"], article.id
  end
end
