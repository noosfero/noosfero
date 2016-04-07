require_relative '../test_helper'
require_relative '../../../../test/api/test_helper'

class APITest <  ActiveSupport::TestCase

  def setup
    login_api
    environment = Environment.default
    environment.enable_plugin(CommentParagraphPlugin)
  end

  should 'return custom parameters for each comment' do
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
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
    article = fast_create(Article, :profile_id => person.id, :name => "Some thing", :published => false)
    comment1 = fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    params[:paragraph_uuid] = '1'
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent [comment1.id], json['comments'].map {|c| c['id']}
  end

end
