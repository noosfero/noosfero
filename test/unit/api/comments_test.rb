require File.dirname(__FILE__) + '/test_helper'

class CommentsTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'return comments of an article' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    article.comments.create!(:body => "some comment", :author => user.person)
    article.comments.create!(:body => "another comment", :author => user.person)

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["comments"].length
  end

end
