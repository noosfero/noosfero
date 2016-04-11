require_relative 'test_helper'

class CommentsTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'not list comments if user has no permission to view the source article' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not return comment if user has no permission to view the source article' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    comment = article.comments.create!(:body => "another comment", :author => user.person)
    assert !article.published?

    get "/api/v1/articles/#{article.id}/comments/#{comment.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not comment an article if user has no permission to view it' do
    person = fast_create(Person)
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    assert !article.published?

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'return comments of an article' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    article.comments.create!(:body => "some comment", :author => user.person)
    article.comments.create!(:body => "another comment", :author => user.person)

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 2, json["comments"].length
  end

  should 'return comment of an article' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    comment = article.comments.create!(:body => "another comment", :author => user.person)

    get "/api/v1/articles/#{article.id}/comments/#{comment.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal comment.id, json['comment']['id']
  end

  should 'comment an article' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    body = 'My comment'
    params.merge!({:body => body})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 201, last_response.status
    assert_equal body, json['comment']['body']
  end

  should 'comment creation define the source' do
    amount = Comment.count
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    body = 'My comment'
    params.merge!({:body => body})

    post "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    assert_equal amount + 1, Comment.count
    comment = Comment.last
    assert_not_nil comment.source
  end

  should 'paginate comments' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    5.times { article.comments.create!(:body => "some comment", :author => user.person) }
    params[:per_page] = 3

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 3, json["comments"].length
  end

  should 'return only root comments' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    comment1 = article.comments.create!(:body => "some comment", :author => user.person)
    comment2 = article.comments.create!(:body => "another comment", :author => user.person, :reply_of_id => comment1.id)
    params[:without_reply] = true

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal [comment1.id], json["comments"].map { |c| c['id'] }
  end

  should 'call plugin hotspot to filter unavailable comments' do
    class Plugin1 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(:user_agent => 'Jack')
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    Environment.default.enable_plugin(Plugin1)

    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    c1 = fast_create(Comment, source_id: article.id, body: "comment 1")
    c2 = fast_create(Comment, source_id: article.id, body: "comment 2", :user_agent => 'Jack')

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ["comment 2"], json["comments"].map {|c| c["body"]}
  end

  should 'do not return comments marked as spam' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    c1 = fast_create(Comment, source_id: article.id, body: "comment 1", spam: true)
    c2 = fast_create(Comment, source_id: article.id, body: "comment 2")

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ["comment 2"], json["comments"].map {|c| c["body"]}
  end
end
