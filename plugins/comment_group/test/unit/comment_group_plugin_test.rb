require File.dirname(__FILE__) + '/../../../../test/test_helper'

class CommentGroupPluginTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = Environment.default
  end
 
  attr_reader :environment

  should 'load_comments returns all the comments wihout group of an article passed as parameter' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id)

    plugin = CommentGroupPlugin.new
    assert_equal [], [c2, c3] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2, c3]
  end
 
  should 'load_comments not returns spam comments' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id, :spam => true)

    plugin = CommentGroupPlugin.new
    assert_equal [], [c2] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2]
  end
 
  should 'load_comments returns only root comments of article' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id, :reply_of_id => c2.id)

    plugin = CommentGroupPlugin.new
    assert_equal [], [c2] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2]
  end
 
end
