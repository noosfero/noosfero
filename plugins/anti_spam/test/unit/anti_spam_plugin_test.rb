require 'test_helper'

class AntiSpamPluginTest < ActiveSupport::TestCase

  def setup
    profile = fast_create(Profile)
    article = fast_create(TextileArticle, :profile_id => profile.id)
    @comment = fast_create(Comment, :source_id => article.id, :source_type => 'Article')


    @suggest_article = SuggestArticle.new(:target_id => profile.id, :target_type => 'Profile', :article_name => 'article', :article_body => 'lorem ipsum', :email => 'invalid@example.com', :name => 'article')

    @suggest_article.save!

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

  should 'report comment spam' do
    AntiSpamPlugin::CommentWrapper.any_instance.expects(:spam!)
    @plugin.comment_marked_as_spam(@comment)
  end

  should 'report comment ham' do
    AntiSpamPlugin::CommentWrapper.any_instance.expects(:ham!)
    @plugin.comment_marked_as_ham(@comment)
  end

  should 'check for spam and mark suggest_article as spam if server says it is spam' do
    AntiSpamPlugin::SuggestArticleWrapper.any_instance.expects(:spam?).returns(true)
    @suggest_article.expects(:save!)

    @plugin.check_suggest_article_for_spam(@suggest_article)
    assert @suggest_article.spam
  end

  should 'report suggest_article spam' do
    AntiSpamPlugin::SuggestArticleWrapper.any_instance.expects(:spam!)
    @plugin.suggest_article_marked_as_spam(@suggest_article)
  end

  should 'report suggest_article ham' do
    AntiSpamPlugin::SuggestArticleWrapper.any_instance.expects(:ham!)
    @plugin.suggest_article_marked_as_ham(@suggest_article)
  end

end
