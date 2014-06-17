require File.dirname(__FILE__) + '/../test_helper'

class AllowCommentTest < ActiveSupport::TestCase

  def setup
    @macro = CommentGroupPlugin::AllowComment.new
  end

  attr_reader :macro

  should 'have a configuration' do
    assert CommentGroupPlugin::AllowComment.configuration
  end

  should 'parse contents to include comment group view' do
    profile = fast_create(Community)
    article = fast_create(Article, :profile_id => profile.id)
    comment = fast_create(Comment, :group_id => 1, :source_id => article.id)
    inner_html = 'inner'
    content = macro.parse({:group_id => comment.group_id}, inner_html, article)

    expects(:render).with({:partial => 'comment_group_plugin_profile/comment_group', :locals => {:group_id => comment.group_id, :article_id => article.id, :inner_html => inner_html, :count => 1, :profile_identifier => profile.identifier} })
    instance_eval(&content)
  end

end
