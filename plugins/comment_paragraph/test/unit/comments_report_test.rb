require_relative '../test_helper'

class CommentsReportTest < ActiveSupport::TestCase

  include CommentParagraphPlugin::CommentsReport
  
  def setup
    profile = fast_create(Community)
    @article = fast_create(Article, :profile_id => profile.id)
  end

  attr_reader :article

  should 'export comments in csv format with the first line as a header' do
    comment1 = fast_create(Comment, :created_at => Time.now - 1.days, :source_id => article, :title => 'a comment', :body => 'a comment', :paragraph_uuid => nil)
    comment2 = fast_create(Comment, :created_at => Time.now - 2.days, :source_id => article, :title => 'b comment', :body => 'b comment', :paragraph_uuid => nil)
    csv = export_comments_csv(article)
    lines = csv.split("\n")
    assert_equal '"paragraph_id","paragraph_text","comment_id","comment_reply_to","comment_title","comment_content","comment_author_name","comment_author_email"', lines.first
    assert_equal "\"\",\"\",\"#{comment2.id}\",\"\",\"b comment\",\"b comment\",\"#{comment2.author_name}\",\"#{comment2.author_email}\"", lines.second
  end

end
