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
end
