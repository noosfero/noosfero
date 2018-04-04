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

  # TODO: implement validation
  should 'allow save if comment paragraph macro is not removed for paragraph with comments' do
    article.body = "<div class=\"macro\" data-macro-paragraph_uuid=0></div>"
    comment1 = fast_create(Comment, :paragraph_uuid => 0, :source_id => article.id)
    assert article.save
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
    assert_nil article.comment_paragraph_plugin_paragraph_content(1)
  end

  should 'be enabled if plugin is enabled and article is a kind of Discussion' do
    assert fast_create(CommentParagraphPlugin::Discussion, profile_id: profile.id).comment_paragraph_plugin_enabled?
  end

  should 'remove paragraph comments if paragraph uuid does not exist' do
    article.body = "<div class=\"macro\" data-macro-paragraph_uuid=1>paragraph content</div>"
    author = fast_create(Person)
    comment1 = article.comments.create!(body: 'comment one', paragraph_uuid: 1,
                                        author: author)
    comment2 = article.comments.create!(body: 'comment two', paragraph_uuid: 2,
                                        author: author)

    article.save
    assert Comment.exists?(comment1)
    refute Comment.exists?(comment2)
  end

  should 'not call remove_zombie_comments if body does not change' do
    article.save
    article.name = 'New name'
    article.expects(:remove_zombie_comments).never
    article.save
  end
end
