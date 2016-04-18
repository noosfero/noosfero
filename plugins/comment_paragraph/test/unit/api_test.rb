require_relative '../test_helper'
require_relative '../../../../test/api/test_helper'

class APITest <  ActiveSupport::TestCase

  def setup
    login_api
    environment.enable_plugin(CommentParagraphPlugin)
  end

  should 'return custom parameters for each comment' do
    article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing", :published => false)
    comment = fast_create(Comment, paragraph_uuid: '1', source_id: article.id, author_id: fast_create(Person).id)
    comment.comment_paragraph_selected_area = 'area'
    comment.comment_paragraph_selected_content = 'content'
    comment.save!
    params[:paragraph_uuid] = '1'
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent ['1'], json['comments'].map {|c| c['paragraph_uuid']}
    assert_equivalent ['area'], json['comments'].map {|c| c['comment_paragraph_selected_area']}
    assert_equivalent ['content'], json['comments'].map {|c| c['comment_paragraph_selected_content']}
  end

  should 'return comments that belongs to a paragraph' do
    article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing", :published => false)
    comment1 = fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    params[:paragraph_uuid] = '1'
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent [comment1.id], json['comments'].map {|c| c['id']}
  end

  {activate: true, deactivate: false}.each do |method, value|
    should "#{method} paragraph comment in an article" do
      article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing", :author_id => person.id)
      post "/api/v1/articles/#{article.id}/comment_paragraph_plugin/#{method}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal value, json["article"]["setting"]["comment_paragraph_plugin_activate"]
    end

    should "not allow #{method} paragraph comment when not logged in" do
      article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing")
      post "/api/v1/articles/#{article.id}/comment_paragraph_plugin/#{method}"
      assert_equal 401, last_response.status
    end

    should "not allow #{method} paragraph comment when user does not have permission to edit article" do
      author = create_user.person
      article = fast_create(TextArticle, :profile_id => author.id, :name => "Some thing", :author_id => author.id)
      post "/api/v1/articles/#{article.id}/comment_paragraph_plugin/#{method}?#{params.to_query}"
      assert_equal 403, last_response.status
    end
  end

  should 'return comment counts grouped by paragraph' do
    article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing", :published => false)
    fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments/count?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equal({"1"=>1, ""=>1, "2"=>2}, json)
  end

  should 'filter comments marked as spam' do
    article = fast_create(TextArticle, :profile_id => person.id, :name => "Some thing", :published => false)
    comment1 = fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id, spam: true)
    comment3 = fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id, spam: true)
    params[:paragraph_uuid] = '1'
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent [comment1.id], json['comments'].map {|c| c['id']}
  end
end
