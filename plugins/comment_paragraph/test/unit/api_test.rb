require_relative "../test_helper"
require_relative "../../../../test/api/test_helper"

class APITest <  ActiveSupport::TestCase
  def setup
    create_and_activate_user
    login_api
    environment.enable_plugin(CommentParagraphPlugin)
  end

  should "return custom parameters for each comment" do
    article = fast_create(TextArticle, profile_id: person.id, name: "Some thing", published: true)
    comment = fast_create(Comment, paragraph_uuid: "1", source_id: article.id, author_id: fast_create(Person).id)
    comment.comment_paragraph_selected_area = "area"
    comment.comment_paragraph_selected_content = "content"
    comment.save!
    params[:paragraph_uuid] = "1"
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent ["1"], json.map { |c| c["paragraph_uuid"] }
    assert_equivalent ["area"], json.map { |c| c["comment_paragraph_selected_area"] }
    assert_equivalent ["content"], json.map { |c| c["comment_paragraph_selected_content"] }
  end

  should "return comments that belongs to a paragraph" do
    article = fast_create(TextArticle, profile_id: person.id, name: "Some thing", published: true)
    comment1 = fast_create(Comment, paragraph_uuid: "1", source_id: article.id)
    comment2 = fast_create(Comment, paragraph_uuid: nil, source_id: article.id)
    comment3 = fast_create(Comment, paragraph_uuid: "2", source_id: article.id)
    params[:paragraph_uuid] = "1"
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent [comment1.id], json.map { |c| c["id"] }
  end

  should "return comment counts grouped by paragraph" do
    article = fast_create(TextArticle, profile_id: person.id, name: "Some thing", published: true)
    fast_create(Comment, paragraph_uuid: "1", source_id: article.id)
    fast_create(Comment, paragraph_uuid: nil, source_id: article.id)
    fast_create(Comment, paragraph_uuid: "2", source_id: article.id)
    fast_create(Comment, paragraph_uuid: "2", source_id: article.id)
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments/count?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equal({ "1" => 1, "" => 1, "2" => 2 }, json)
  end

  should "filter comments marked as spam" do
    article = fast_create(TextArticle,
                          profile_id: person.id,
                          name: "Some thing",
                          published: true)
    comment1 = fast_create(Comment, paragraph_uuid: "1", source_id: article.id)
    comment2 = fast_create(Comment, paragraph_uuid: nil, source_id: article.id, spam: true)
    comment3 = fast_create(Comment, paragraph_uuid: "2", source_id: article.id, spam: true)
    params[:paragraph_uuid] = "1"
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/comments?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent [comment1.id], json.map { |c| c["id"] }
  end

  should "create discussion article" do
    article = fast_create(Article, profile_id: person.id)
    params[:article] = { name: "Title", type: "CommentParagraphPlugin::Discussion" }
    post "/api/v1/articles/#{article.id}/children?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal "CommentParagraphPlugin::Discussion", json["type"]
  end

  should "export comments" do
    login_api
    article = fast_create(Article, profile_id: person.id, name: "Some thing")
    comment1 = fast_create(Comment, created_at: Time.now - 1.days, source_id: article, title: "a comment", body: "a comment", paragraph_uuid: nil)
    comment2 = fast_create(Comment, created_at: Time.now - 2.days, source_id: article, title: "b comment", body: "b comment", paragraph_uuid: nil)
    get "/api/v1/articles/#{article.id}/comment_paragraph_plugin/export?#{params.to_query}"
    assert_equal 200, last_response.status
    assert_equal "text/csv; charset=UTF-8; header=present", last_response.content_type
    json = JSON.parse(last_response.body)
    lines = json["data"].to_s.split("\n")
    assert_equal '"paragraph_id","paragraph_text","comment_id","comment_reply_to","comment_title","comment_content","comment_author_name","comment_author_email","comment_date"', lines.first
    assert_equal "\"\",\"\",\"#{comment2.id}\",\"\",\"b comment\",\"b comment\",\"#{comment2.author_name}\",\"#{comment2.author_email}\",\"#{comment2.created_at}\"", lines.second
    assert_match /#{article.slug}/, last_response.original_headers["Content-Disposition"]
  end
end
