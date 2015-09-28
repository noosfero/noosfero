require_relative '../test_helper'
require 'benchmark'

class ArticleTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @article = fast_create(TextArticle, :profile_id => profile.id)
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)
  end

  attr_reader :article, :environment, :profile

  should 'return paragraph comments from article' do
    comment1 = fast_create(Comment, :paragraph_uuid => 1, :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    assert_equal [comment1], article.paragraph_comments
  end

  should 'allow save if comment paragraph macro is not removed for paragraph with comments' do
    article.body = "<div class=\"macro\" data-macro-paragraph_uuid=0></div>"
    comment1 = fast_create(Comment, :paragraph_uuid => 0, :source_id => article.id)
    assert article.save
  end

  should 'not parse html if the plugin is not enabled' do
    article.body = "<p>paragraph 1</p><p>paragraph 2</p>"
    environment.disable_plugin(CommentParagraphPlugin)
    assert !environment.plugin_enabled?(CommentParagraphPlugin)
    article.save!
    assert_equal "<p>paragraph 1</p><p>paragraph 2</p>", article.body
  end

  should 'parse html if the plugin is not enabled' do
    article.body = "<p>paragraph 1</p><div>div 1</div><span>span 1</span>"
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    assert_mark_paragraph article.body, 'div', 'div 1'
    assert_mark_paragraph article.body, 'span', 'span 1'
  end

  should 'parse html li when activate comment paragraph' do
    article.body = '<ul><li class="custom_class">item1</li><li>item2</li></ul>'
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'li', 'item1'
    assert_mark_paragraph article.body, 'li', 'item2'
  end

  should 'parse inner html li when activate comment paragraph' do
    article.body = '<div><ul><li class="custom_class">item1</li><li>item2</li></ul><div>'
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'li', 'item1'
    assert_mark_paragraph article.body, 'li', 'item2'
  end

  should 'do not remove macro div when disable comment paragraph' do
    article.body = "<p>paragraph 1</p>"
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    article.comment_paragraph_plugin_activate = false
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
  end

  should 'parse html when activate comment paragraph' do
    article.body = "<p>paragraph 1</p><p>paragraph 2</p>"
    article.comment_paragraph_plugin_activate = false
    article.save!
    assert_equal "<p>paragraph 1</p><p>paragraph 2</p>", article.body
    article.comment_paragraph_plugin_activate = true
    article.save!

    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    assert_mark_paragraph article.body, 'p', 'paragraph 2'
  end

  should 'parse html when add new paragraph' do
    article.body = "<p>paragraph 1</p>"
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'

    article.body += "<p>paragraph 2</p>"
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    assert_mark_paragraph article.body, 'p', 'paragraph 2'
  end

  should 'keep already marked paragraph attributes when add new paragraph' do
    article.body = "<p>paragraph 1</p>"
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    uuid = Nokogiri::HTML(article.body).at('p span.paragraph_comment')['data-macro-paragraph_uuid']

    article.body += "<p>paragraph 2</p>"
    article.save!
    assert_mark_paragraph article.body, 'p', 'paragraph 1'
    new_uuid = Nokogiri::HTML(article.body).at('p span.paragraph_comment')['data-macro-paragraph_uuid']
    assert_equal uuid, new_uuid
  end

  should 'not parse empty element' do
    article.body = '<div></div>'
    article.comment_paragraph_plugin_activate = true
    article.save!
    assert_equal '<div></div>', article.body
  end

  should 'be enabled if plugin is enabled and article is a kind of TextArticle' do
    assert article.comment_paragraph_plugin_enabled?
  end

  should 'not be enabled if plugin is not enabled' do
    environment.disable_plugin(CommentParagraphPlugin)
    assert !article.comment_paragraph_plugin_enabled?
  end

  should 'not be enabled if article if not a kind of TextArticle' do
    article = fast_create(Article, :profile_id => profile.id)
    assert !article.comment_paragraph_plugin_enabled?
  end

  should 'not be activated by default' do
    article = fast_create(TextArticle, :profile_id => profile.id)
    assert !article.comment_paragraph_plugin_activated?
  end

  should 'be activated by default if it is enabled and activation mode is auto' do
    settings = Noosfero::Plugin::Settings.new(environment, CommentParagraphPlugin)
    settings.activation_mode = 'auto'
    settings.save!
    article = TextArticle.create!(:profile => profile, :name => 'title')
    assert article.comment_paragraph_plugin_activated?
  end

  should 'be activated when forced' do
    article.comment_paragraph_plugin_activate = true
    assert article.comment_paragraph_plugin_activated?
  end

  should 'not be activated if plugin is not enabled' do
    article.comment_paragraph_plugin_activate = true
    environment.disable_plugin(CommentParagraphPlugin)
    assert !article.comment_paragraph_plugin_enabled?
  end

  should 'append not_logged to cache key when user is not logged in' do
    assert_match /-not_logged-/, article.cache_key
  end

  should 'append logged_in to cache key when user is logged in' do
    assert_match /-logged_in-/, article.cache_key({}, fast_create(Person))
  end

  should 'return paragraph content passing paragraph uuid' do
    uuid = 0
    article.body = "<div class=\"macro\" data-macro-paragraph_uuid=#{uuid}>paragraph content</div>"
    assert_equal 'paragraph content', article.comment_paragraph_plugin_paragraph_content(uuid)
  end

  should 'return nil as paragraph content when paragraph uuid is not found' do
    uuid = 0
    article.body = "<div class=\"macro\" data-macro-paragraph_uuid=#{uuid}>paragraph content</div>"
    assert_equal nil, article.comment_paragraph_plugin_paragraph_content(1)
  end

end
