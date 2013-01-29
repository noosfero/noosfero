require 'test_helper'

class AntiSpamPluginTest < ActiveSupport::TestCase

  def setup
    profile = fast_create(Profile)
    article = fast_create(TextileArticle, :profile_id => profile.id)
    @comment = fast_create(Comment, :source_id => article.id, :source_type => 'Article')

    @settings = Noosfero::Plugin::Settings.new(@comment.environment, AntiSpamPlugin)
    @settings.api_key = 'b8b80ddb8084062d0c9119c945ce3bc3'
    @settings.save!

    @plugin = AntiSpamPlugin.new
    @plugin.context = @comment
  end

  should 'check for spam and mark comment as spam if server says it is spam' do
    AntiSpamPlugin::CommentWrapper.any_instance.expects(:spam?).returns(true)
    @comment.expects(:save!)

    @plugin.check_comment_for_spam(@comment)
    assert @comment.spam
  end

  should 'report spam' do
    AntiSpamPlugin::CommentWrapper.any_instance.expects(:spam!)
    @plugin.comment_marked_as_spam(@comment)
  end

  should 'report ham' do
    AntiSpamPlugin::CommentWrapper.any_instance.expects(:ham!)
    @plugin.comment_marked_as_ham(@comment)
  end

end
