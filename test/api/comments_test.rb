require_relative 'test_helper'

class CommentsTest < ActiveSupport::TestCase

  def setup
    @local_person = fast_create(Person)
    create_and_activate_user
  end

  should 'logged user not list comments if user has no permission to view the source article' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'logged user not return comment if user has no permission to view the source article' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing", :published => false)
    comment = article.comments.create!(:body => "another comment", :author => @local_person)
    assert !article.published?

    get "/api/v1/articles/#{article.id}/comments/#{comment.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'logged user not comment an article if user has no permission to view it' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing", :published => false)
    assert !article.published?

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'logged user return comments of an article' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    article.comments.create!(:body => "some comment", :author => @local_person)
    article.comments.create!(:body => "another comment", :author => @local_person)

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 2, json["comments"].length
  end

  should 'logged user return comment of an article' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    comment = article.comments.create!(:body => "another comment", :author => @local_person)

    get "/api/v1/articles/#{article.id}/comments/#{comment.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal comment.id, json['comment']['id']
  end

  should 'logged user comment an article' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    body = 'My comment'
    params.merge!({:body => body})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal body, json['comment']['body']
  end

  should 'logged user not comment an archived article' do
    login_api
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing", :archived => true)
    body = 'My comment'
    params.merge!({:body => body})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 400, last_response.status
  end

  should 'logged user comment creation define the source' do
    login_api
    amount = Comment.count
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    body = 'My comment'
    params.merge!({:body => body})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal amount + 1, Comment.count
    comment = Comment.last
    assert_not_nil comment.source
  end

  should 'call plugin hotspot to filter unavailable comments' do
    class Plugin1 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(:user_agent => 'Jack')
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    Environment.default.enable_plugin(Plugin1)

    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    c1 = fast_create(Comment, source_id: article.id, body: "comment 1")
    c2 = fast_create(Comment, source_id: article.id, body: "comment 2", :user_agent => 'Jack')

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ["comment 2"], json["comments"].map {|c| c["body"]}
  end

  should 'anonymous do not return comments marked as spam' do
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    c1 = fast_create(Comment, source_id: article.id, body: "comment 1", spam: true)
    c2 = fast_create(Comment, source_id: article.id, body: "comment 2")
    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ["comment 2"], json["comments"].map {|c| c["body"]}
  end

  should 'not list comments if anonymous has no permission to view the source article' do
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'return comments of an article for anonymous' do
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    article.comments.create!(:body => "some comment", :author => @local_person)
    article.comments.create!(:body => "another comment", :author => @local_person)

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 2, json["comments"].length
  end

  should 'return comment of an article for anonymous' do
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    comment = article.comments.create!(:body => "another comment", :author => @local_person)

    get "/api/v1/articles/#{article.id}/comments/#{comment.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal comment.id, json['comment']['id']
  end

  should 'anonymous user not comment an article' do
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing")
    body = 'My comment'
    name = "John Doe"
    email = "JohnDoe@gmail.com"
    params.merge!({:body => body, name: name, email: email})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 401, last_response.status
  end

  should 'logged user paginate comments' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    5.times { article.comments.create!(:body => "some comment", :author => @local_person) }
    params[:per_page] = 3

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 3, json["comments"].length
  end

  should 'logged user return only root comments' do
    login_api
    article = fast_create(Article, :profile_id => @local_person.id, :name => "Some thing")
    comment1 = article.comments.create!(:body => "some comment", :author => @local_person)
    comment2 = article.comments.create!(:body => "another comment", :author => @local_person, :reply_of_id => comment1.id)
    params[:without_reply] = true

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal [comment1.id], json["comments"].map { |c| c['id'] }
  end

end
